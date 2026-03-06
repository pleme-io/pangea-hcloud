# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_rdns/resource'
require 'pangea/resources/hcloud_rdns/types'

RSpec.describe 'hcloud_rdns synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes reverse DNS entry' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_rdns(:server_rdns, {
          server_id: "${hcloud_server.production.id}",
          ip_address: "${hcloud_server.production.ipv4_address}",
          dns_ptr: "production.example.com"
        })
      end

      result = synthesizer.synthesis
      rdns = result[:resource][:hcloud_rdns][:server_rdns]

      expect(rdns[:dns_ptr]).to eq("production.example.com")
    end

    it 'synthesizes reverse DNS with literal IP' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_rdns(:static_rdns, {
          server_id: "srv-123",
          ip_address: "203.0.113.50",
          dns_ptr: "mail.example.com"
        })
      end

      result = synthesizer.synthesis
      rdns = result[:resource][:hcloud_rdns][:static_rdns]

      expect(rdns[:server_id]).to eq("srv-123")
      expect(rdns[:ip_address]).to eq("203.0.113.50")
      expect(rdns[:dns_ptr]).to eq("mail.example.com")
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_rdns(:test, {
          server_id: "srv-123",
          ip_address: "1.2.3.4",
          dns_ptr: "test.example.com"
        })
      end

      expect(ref.id).to eq("${hcloud_rdns.test.id}")
      expect(ref.outputs[:server_id]).to eq("${hcloud_rdns.test.server_id}")
      expect(ref.outputs[:ip_address]).to eq("${hcloud_rdns.test.ip_address}")
      expect(ref.outputs[:dns_ptr]).to eq("${hcloud_rdns.test.dns_ptr}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required server_id' do
      expect {
        Pangea::Resources::Hetzner::Types::RdnsAttributes.new(
          ip_address: "1.2.3.4", dns_ptr: "test.example.com"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required ip_address' do
      expect {
        Pangea::Resources::Hetzner::Types::RdnsAttributes.new(
          server_id: "srv-123", dns_ptr: "test.example.com"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required dns_ptr' do
      expect {
        Pangea::Resources::Hetzner::Types::RdnsAttributes.new(
          server_id: "srv-123", ip_address: "1.2.3.4"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts valid attributes' do
      attrs = Pangea::Resources::Hetzner::Types::RdnsAttributes.new(
        server_id: "srv-123", ip_address: "1.2.3.4", dns_ptr: "test.example.com"
      )
      expect(attrs.server_id).to eq("srv-123")
      expect(attrs.ip_address).to eq("1.2.3.4")
      expect(attrs.dns_ptr).to eq("test.example.com")
    end
  end
end
