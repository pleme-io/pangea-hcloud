# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_load_balancer/resource'
require 'pangea/resources/hcloud_load_balancer/types'

RSpec.describe 'hcloud_load_balancer synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes basic load balancer' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer(:app_lb, {
          name: "app-load-balancer",
          load_balancer_type: "lb11",
          location: "fsn1"
        })
      end

      result = synthesizer.synthesis
      lb = result[:resource][:hcloud_load_balancer][:app_lb]

      expect(lb[:name]).to eq("app-load-balancer")
      expect(lb[:load_balancer_type]).to eq("lb11")
      expect(lb[:location]).to eq("fsn1")
    end

    it 'synthesizes load balancer with network_zone' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer(:regional, {
          name: "regional-lb",
          load_balancer_type: "lb21",
          network_zone: "eu-central"
        })
      end

      result = synthesizer.synthesis
      lb = result[:resource][:hcloud_load_balancer][:regional]

      expect(lb[:network_zone]).to eq("eu-central")
    end

    it 'synthesizes load balancer with algorithm' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer(:algo_lb, {
          name: "algo-lb",
          load_balancer_type: "lb11",
          location: "fsn1",
          algorithm: { type: "least_connections" }
        })
      end

      result = synthesizer.synthesis
      lb = result[:resource][:hcloud_load_balancer][:algo_lb]

      expect(lb[:algorithm][:type]).to eq("least_connections")
    end

    it 'synthesizes load balancer with labels' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer(:labeled, {
          name: "labeled-lb",
          load_balancer_type: "lb31",
          location: "nbg1",
          labels: { tier: "frontend", env: "production" }
        })
      end

      result = synthesizer.synthesis
      lb = result[:resource][:hcloud_load_balancer][:labeled]

      expect(lb[:labels][:tier]).to eq("frontend")
      expect(lb[:labels][:env]).to eq("production")
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer(:test, {
          name: "test-lb",
          load_balancer_type: "lb11",
          location: "fsn1"
        })
      end

      expect(ref.id).to eq("${hcloud_load_balancer.test.id}")
      expect(ref.outputs[:ipv4]).to eq("${hcloud_load_balancer.test.ipv4}")
      expect(ref.outputs[:ipv6]).to eq("${hcloud_load_balancer.test.ipv6}")
    end

    it 'includes all expected output references' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer(:lb, {
          name: "lb",
          load_balancer_type: "lb11"
        })
      end

      expect(ref.outputs).to include(:id, :name, :ipv4, :ipv6)
    end
  end

  describe 'type validation' do
    it 'rejects missing required name' do
      expect {
        Pangea::Resources::Hetzner::Types::LoadBalancerAttributes.new(
          load_balancer_type: "lb11"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required load_balancer_type' do
      expect {
        Pangea::Resources::Hetzner::Types::LoadBalancerAttributes.new(
          name: "test-lb"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid load_balancer_type' do
      expect {
        Pangea::Resources::Hetzner::Types::LoadBalancerAttributes.new(
          name: "test-lb", load_balancer_type: "lb99"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts all valid load balancer types' do
      %w[lb11 lb21 lb31].each do |lbt|
        attrs = Pangea::Resources::Hetzner::Types::LoadBalancerAttributes.new(
          name: "test", load_balancer_type: lbt
        )
        expect(attrs.load_balancer_type).to eq(lbt)
      end
    end

    it 'rejects invalid network_zone' do
      expect {
        Pangea::Resources::Hetzner::Types::LoadBalancerAttributes.new(
          name: "test", load_balancer_type: "lb11", network_zone: "invalid"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'defaults optional attributes correctly' do
      attrs = Pangea::Resources::Hetzner::Types::LoadBalancerAttributes.new(
        name: "test", load_balancer_type: "lb11"
      )
      expect(attrs.location).to be_nil
      expect(attrs.network_zone).to be_nil
      expect(attrs.algorithm).to be_nil
      expect(attrs.labels).to eq({})
    end
  end
end
