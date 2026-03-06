# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_load_balancer_target/resource'
require 'pangea/resources/hcloud_load_balancer_target/types'

RSpec.describe 'hcloud_load_balancer_target synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes server target' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer_target(:target1, {
          load_balancer_id: "${hcloud_load_balancer.app_lb.id}",
          type: "server",
          server_id: "${hcloud_server.web01.id}",
          use_private_ip: true
        })
      end

      result = synthesizer.synthesis
      lbt = result[:resource][:hcloud_load_balancer_target][:target1]

      expect(lbt[:type]).to eq("server")
      expect(lbt[:use_private_ip]).to be true
    end

    it 'synthesizes label_selector target' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer_target(:label_target, {
          load_balancer_id: "lb-123",
          type: "label_selector",
          label_selector: "role=web"
        })
      end

      result = synthesizer.synthesis
      lbt = result[:resource][:hcloud_load_balancer_target][:label_target]

      expect(lbt[:type]).to eq("label_selector")
      expect(lbt[:label_selector]).to eq("role=web")
    end

    it 'synthesizes ip target' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer_target(:ip_target, {
          load_balancer_id: "lb-123",
          type: "ip",
          ip: "10.0.1.50"
        })
      end

      result = synthesizer.synthesis
      lbt = result[:resource][:hcloud_load_balancer_target][:ip_target]

      expect(lbt[:type]).to eq("ip")
      expect(lbt[:ip]).to eq("10.0.1.50")
    end

    it 'defaults use_private_ip to false' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer_target(:default, {
          load_balancer_id: "lb-123",
          type: "server",
          server_id: "srv-456"
        })
      end

      result = synthesizer.synthesis
      lbt = result[:resource][:hcloud_load_balancer_target][:default]

      expect(lbt[:use_private_ip]).to be false
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer_target(:test, {
          load_balancer_id: "lb-123",
          type: "server",
          server_id: "srv-456"
        })
      end

      expect(ref.id).to eq("${hcloud_load_balancer_target.test.id}")
      expect(ref.outputs[:type]).to eq("${hcloud_load_balancer_target.test.type}")
      expect(ref.outputs[:server_id]).to eq("${hcloud_load_balancer_target.test.server_id}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required load_balancer_id' do
      expect {
        Pangea::Resources::Hetzner::Types::LoadBalancerTargetAttributes.new(
          type: "server"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required type' do
      expect {
        Pangea::Resources::Hetzner::Types::LoadBalancerTargetAttributes.new(
          load_balancer_id: "lb-123"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid type' do
      expect {
        Pangea::Resources::Hetzner::Types::LoadBalancerTargetAttributes.new(
          load_balancer_id: "lb-123", type: "invalid"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts all valid target types' do
      %w[server label_selector ip].each do |t|
        attrs = Pangea::Resources::Hetzner::Types::LoadBalancerTargetAttributes.new(
          load_balancer_id: "lb-123", type: t
        )
        expect(attrs.type).to eq(t)
      end
    end

    it 'defaults optional attributes correctly' do
      attrs = Pangea::Resources::Hetzner::Types::LoadBalancerTargetAttributes.new(
        load_balancer_id: "lb-123", type: "server"
      )
      expect(attrs.server_id).to be_nil
      expect(attrs.label_selector).to be_nil
      expect(attrs.ip).to be_nil
      expect(attrs.use_private_ip).to be false
    end
  end
end
