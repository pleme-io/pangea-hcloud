# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_network_route/resource'
require 'pangea/resources/hcloud_network_route/types'

RSpec.describe 'hcloud_network_route synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes network route' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_network_route(:custom_route, {
          network_id: "${hcloud_network.private.id}",
          destination: "10.100.0.0/16",
          gateway: "10.0.1.1"
        })
      end

      result = synthesizer.synthesis
      route = result[:resource][:hcloud_network_route][:custom_route]

      expect(route[:network_id]).to eq("${hcloud_network.private.id}")
      expect(route[:destination]).to eq("10.100.0.0/16")
      expect(route[:gateway]).to eq("10.0.1.1")
    end

    it 'synthesizes route with different CIDR range' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_network_route(:vpn_route, {
          network_id: "net-123",
          destination: "192.168.0.0/24",
          gateway: "10.0.0.1"
        })
      end

      result = synthesizer.synthesis
      route = result[:resource][:hcloud_network_route][:vpn_route]

      expect(route[:destination]).to eq("192.168.0.0/24")
      expect(route[:gateway]).to eq("10.0.0.1")
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_network_route(:test, {
          network_id: "net-123",
          destination: "10.100.0.0/16",
          gateway: "10.0.1.1"
        })
      end

      expect(ref.id).to eq("${hcloud_network_route.test.id}")
      expect(ref.outputs[:destination]).to eq("${hcloud_network_route.test.destination}")
      expect(ref.outputs[:gateway]).to eq("${hcloud_network_route.test.gateway}")
      expect(ref.outputs[:network_id]).to eq("${hcloud_network_route.test.network_id}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required network_id' do
      expect {
        Pangea::Resources::Hetzner::Types::NetworkRouteAttributes.new(
          destination: "10.100.0.0/16", gateway: "10.0.1.1"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required destination' do
      expect {
        Pangea::Resources::Hetzner::Types::NetworkRouteAttributes.new(
          network_id: "net-123", gateway: "10.0.1.1"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required gateway' do
      expect {
        Pangea::Resources::Hetzner::Types::NetworkRouteAttributes.new(
          network_id: "net-123", destination: "10.100.0.0/16"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid destination CIDR' do
      expect {
        Pangea::Resources::Hetzner::Types::NetworkRouteAttributes.new(
          network_id: "net-123", destination: "not-cidr", gateway: "10.0.1.1"
        )
      }.to raise_error(Dry::Struct::Error)
    end
  end
end
