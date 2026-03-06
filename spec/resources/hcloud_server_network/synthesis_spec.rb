# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_server_network/resource'
require 'pangea/resources/hcloud_server_network/types'

RSpec.describe 'hcloud_server_network synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes server network attachment with static IP' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server_network(:web01_net, {
          server_id: "${hcloud_server.web01.id}",
          network_id: "${hcloud_network.private.id}",
          ip: "10.0.1.10"
        })
      end

      result = synthesizer.synthesis
      sn = result[:resource][:hcloud_server_network][:web01_net]

      expect(sn[:server_id]).to eq("${hcloud_server.web01.id}")
      expect(sn[:network_id]).to eq("${hcloud_network.private.id}")
      expect(sn[:ip]).to eq("10.0.1.10")
    end

    it 'synthesizes server network without static IP (DHCP)' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server_network(:dhcp_net, {
          server_id: "srv-123",
          network_id: "net-456"
        })
      end

      result = synthesizer.synthesis
      sn = result[:resource][:hcloud_server_network][:dhcp_net]

      expect(sn[:server_id]).to eq("srv-123")
      expect(sn[:network_id]).to eq("net-456")
    end

    it 'synthesizes server network with alias IPs' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server_network(:alias_net, {
          server_id: "srv-123",
          network_id: "net-456",
          ip: "10.0.1.10",
          alias_ips: ["10.0.1.11", "10.0.1.12"]
        })
      end

      result = synthesizer.synthesis
      sn = result[:resource][:hcloud_server_network][:alias_net]

      expect(sn[:alias_ips]).to eq(["10.0.1.11", "10.0.1.12"])
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server_network(:test, {
          server_id: "srv-123",
          network_id: "net-456"
        })
      end

      expect(ref.id).to eq("${hcloud_server_network.test.id}")
      expect(ref.outputs[:ip]).to eq("${hcloud_server_network.test.ip}")
      expect(ref.outputs[:server_id]).to eq("${hcloud_server_network.test.server_id}")
      expect(ref.outputs[:network_id]).to eq("${hcloud_server_network.test.network_id}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required server_id' do
      expect {
        Pangea::Resources::Hetzner::Types::ServerNetworkAttributes.new(
          network_id: "net-456"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required network_id' do
      expect {
        Pangea::Resources::Hetzner::Types::ServerNetworkAttributes.new(
          server_id: "srv-123"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'defaults ip to nil' do
      attrs = Pangea::Resources::Hetzner::Types::ServerNetworkAttributes.new(
        server_id: "srv-123", network_id: "net-456"
      )
      expect(attrs.ip).to be_nil
    end

    it 'defaults alias_ips to empty array' do
      attrs = Pangea::Resources::Hetzner::Types::ServerNetworkAttributes.new(
        server_id: "srv-123", network_id: "net-456"
      )
      expect(attrs.alias_ips).to eq([])
    end
  end
end
