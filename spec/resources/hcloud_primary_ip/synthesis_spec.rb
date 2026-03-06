# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_primary_ip/resource'
require 'pangea/resources/hcloud_primary_ip/types'

RSpec.describe 'hcloud_primary_ip synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes primary IP with datacenter' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_primary_ip(:production_ip, {
          name: "production-primary-ip",
          type: "ipv4",
          assignee_type: "server",
          datacenter: "fsn1-dc14",
          auto_delete: false
        })
      end

      result = synthesizer.synthesis
      pip = result[:resource][:hcloud_primary_ip][:production_ip]

      expect(pip[:type]).to eq("ipv4")
      expect(pip[:auto_delete]).to be false
    end

    it 'synthesizes ipv6 primary IP' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_primary_ip(:ipv6_ip, {
          name: "ipv6-primary",
          type: "ipv6",
          assignee_type: "server"
        })
      end

      result = synthesizer.synthesis
      pip = result[:resource][:hcloud_primary_ip][:ipv6_ip]

      expect(pip[:type]).to eq("ipv6")
    end

    it 'synthesizes primary IP with assignee_id' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_primary_ip(:assigned, {
          name: "assigned-ip",
          type: "ipv4",
          assignee_type: "server",
          assignee_id: "${hcloud_server.web.id}"
        })
      end

      result = synthesizer.synthesis
      pip = result[:resource][:hcloud_primary_ip][:assigned]

      expect(pip[:assignee_id]).to eq("${hcloud_server.web.id}")
    end

    it 'synthesizes primary IP with labels' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_primary_ip(:labeled, {
          name: "labeled-ip",
          type: "ipv4",
          assignee_type: "server",
          labels: { purpose: "web", env: "production" }
        })
      end

      result = synthesizer.synthesis
      pip = result[:resource][:hcloud_primary_ip][:labeled]

      expect(pip[:labels][:purpose]).to eq("web")
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_primary_ip(:test, {
          name: "test-ip",
          type: "ipv4",
          assignee_type: "server"
        })
      end

      expect(ref.id).to eq("${hcloud_primary_ip.test.id}")
      expect(ref.outputs[:ip_address]).to eq("${hcloud_primary_ip.test.ip_address}")
      expect(ref.outputs[:name]).to eq("${hcloud_primary_ip.test.name}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required name' do
      expect {
        Pangea::Resources::Hetzner::Types::PrimaryIpAttributes.new(
          type: "ipv4", assignee_type: "server"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required type' do
      expect {
        Pangea::Resources::Hetzner::Types::PrimaryIpAttributes.new(
          name: "test", assignee_type: "server"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required assignee_type' do
      expect {
        Pangea::Resources::Hetzner::Types::PrimaryIpAttributes.new(
          name: "test", type: "ipv4"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid type' do
      expect {
        Pangea::Resources::Hetzner::Types::PrimaryIpAttributes.new(
          name: "test", type: "ipv5", assignee_type: "server"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid assignee_type' do
      expect {
        Pangea::Resources::Hetzner::Types::PrimaryIpAttributes.new(
          name: "test", type: "ipv4", assignee_type: "load_balancer"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'defaults auto_delete to true' do
      attrs = Pangea::Resources::Hetzner::Types::PrimaryIpAttributes.new(
        name: "test", type: "ipv4", assignee_type: "server"
      )
      expect(attrs.auto_delete).to be true
    end

    it 'defaults optional attributes to nil' do
      attrs = Pangea::Resources::Hetzner::Types::PrimaryIpAttributes.new(
        name: "test", type: "ipv4", assignee_type: "server"
      )
      expect(attrs.assignee_id).to be_nil
      expect(attrs.datacenter).to be_nil
    end

    it 'defaults labels to empty hash' do
      attrs = Pangea::Resources::Hetzner::Types::PrimaryIpAttributes.new(
        name: "test", type: "ipv4", assignee_type: "server"
      )
      expect(attrs.labels).to eq({})
    end
  end
end
