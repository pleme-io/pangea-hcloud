# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_network_subnet/resource'
require 'pangea/resources/hcloud_network_subnet/types'

RSpec.describe 'hcloud_network_subnet synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes cloud subnet' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_network_subnet(:subnet, {
          network_id: "${hcloud_network.private.id}",
          type: "cloud",
          network_zone: "eu-central",
          ip_range: "10.0.1.0/24"
        })
      end

      result = synthesizer.synthesis
      subnet = result[:resource][:hcloud_network_subnet][:subnet]

      expect(subnet[:network_id]).to eq("${hcloud_network.private.id}")
      expect(subnet[:type]).to eq("cloud")
      expect(subnet[:network_zone]).to eq("eu-central")
      expect(subnet[:ip_range]).to eq("10.0.1.0/24")
    end

    it 'synthesizes server subnet' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_network_subnet(:server_sub, {
          network_id: "net-123",
          type: "server",
          network_zone: "eu-central",
          ip_range: "10.0.2.0/24"
        })
      end

      result = synthesizer.synthesis
      subnet = result[:resource][:hcloud_network_subnet][:server_sub]

      expect(subnet[:type]).to eq("server")
    end

    it 'synthesizes vswitch subnet with vswitch_id' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_network_subnet(:vswitch_sub, {
          network_id: "net-123",
          type: "vswitch",
          network_zone: "eu-central",
          ip_range: "10.0.3.0/24",
          vswitch_id: 12345
        })
      end

      result = synthesizer.synthesis
      subnet = result[:resource][:hcloud_network_subnet][:vswitch_sub]

      expect(subnet[:type]).to eq("vswitch")
      expect(subnet[:vswitch_id]).to eq(12345)
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_network_subnet(:test, {
          network_id: "net-123",
          type: "cloud",
          network_zone: "eu-central",
          ip_range: "10.0.1.0/24"
        })
      end

      expect(ref.id).to eq("${hcloud_network_subnet.test.id}")
      expect(ref.outputs[:gateway]).to eq("${hcloud_network_subnet.test.gateway}")
      expect(ref.outputs[:ip_range]).to eq("${hcloud_network_subnet.test.ip_range}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required network_id' do
      expect {
        Pangea::Resources::Hetzner::Types::NetworkSubnetAttributes.new(
          type: "cloud", network_zone: "eu-central", ip_range: "10.0.1.0/24"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required type' do
      expect {
        Pangea::Resources::Hetzner::Types::NetworkSubnetAttributes.new(
          network_id: "net-123", network_zone: "eu-central", ip_range: "10.0.1.0/24"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid subnet type' do
      expect {
        Pangea::Resources::Hetzner::Types::NetworkSubnetAttributes.new(
          network_id: "net-123", type: "invalid", network_zone: "eu-central", ip_range: "10.0.1.0/24"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid network_zone' do
      expect {
        Pangea::Resources::Hetzner::Types::NetworkSubnetAttributes.new(
          network_id: "net-123", type: "cloud", network_zone: "invalid", ip_range: "10.0.1.0/24"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid ip_range CIDR' do
      expect {
        Pangea::Resources::Hetzner::Types::NetworkSubnetAttributes.new(
          network_id: "net-123", type: "cloud", network_zone: "eu-central", ip_range: "not-cidr"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts all valid subnet types' do
      %w[cloud server vswitch].each do |t|
        attrs = Pangea::Resources::Hetzner::Types::NetworkSubnetAttributes.new(
          network_id: "net-123", type: t, network_zone: "eu-central", ip_range: "10.0.1.0/24"
        )
        expect(attrs.type).to eq(t)
      end
    end

    it 'accepts all valid network zones' do
      %w[eu-central us-east us-west ap-southeast].each do |nz|
        attrs = Pangea::Resources::Hetzner::Types::NetworkSubnetAttributes.new(
          network_id: "net-123", type: "cloud", network_zone: nz, ip_range: "10.0.1.0/24"
        )
        expect(attrs.network_zone).to eq(nz)
      end
    end

    it 'defaults vswitch_id to nil' do
      attrs = Pangea::Resources::Hetzner::Types::NetworkSubnetAttributes.new(
        network_id: "net-123", type: "cloud", network_zone: "eu-central", ip_range: "10.0.1.0/24"
      )
      expect(attrs.vswitch_id).to be_nil
    end
  end
end
