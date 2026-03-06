# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_floating_ip/resource'
require 'pangea/resources/hcloud_floating_ip/types'

RSpec.describe 'hcloud_floating_ip synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes ipv4 floating IP with location' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_floating_ip(:lb_ip, {
          type: "ipv4",
          home_location: "fsn1",
          description: "Load balancer public IP"
        })
      end

      result = synthesizer.synthesis
      fip = result[:resource][:hcloud_floating_ip][:lb_ip]

      expect(fip[:type]).to eq("ipv4")
      expect(fip[:home_location]).to eq("fsn1")
    end

    it 'synthesizes ipv6 floating IP' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_floating_ip(:ipv6, {
          type: "ipv6",
          home_location: "nbg1"
        })
      end

      result = synthesizer.synthesis
      fip = result[:resource][:hcloud_floating_ip][:ipv6]

      expect(fip[:type]).to eq("ipv6")
    end

    it 'synthesizes floating IP with server_id' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_floating_ip(:server_ip, {
          type: "ipv4",
          server_id: "${hcloud_server.web.id}"
        })
      end

      result = synthesizer.synthesis
      fip = result[:resource][:hcloud_floating_ip][:server_ip]

      expect(fip[:server_id]).to eq("${hcloud_server.web.id}")
    end

    it 'synthesizes floating IP with labels and name' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_floating_ip(:named, {
          type: "ipv4",
          home_location: "fsn1",
          name: "production-lb-ip",
          labels: { role: "load-balancer" }
        })
      end

      result = synthesizer.synthesis
      fip = result[:resource][:hcloud_floating_ip][:named]

      expect(fip[:name]).to eq("production-lb-ip")
      expect(fip[:labels][:role]).to eq("load-balancer")
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_floating_ip(:test, {
          type: "ipv4",
          home_location: "fsn1"
        })
      end

      expect(ref.id).to eq("${hcloud_floating_ip.test.id}")
      expect(ref.outputs[:ip_address]).to eq("${hcloud_floating_ip.test.ip_address}")
      expect(ref.outputs[:home_location]).to eq("${hcloud_floating_ip.test.home_location}")
    end

    it 'includes all expected output references' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_floating_ip(:fip, {
          type: "ipv4",
          home_location: "fsn1"
        })
      end

      expect(ref.outputs).to include(:id, :ip_address, :name, :home_location)
    end
  end

  describe 'type validation' do
    it 'rejects missing required type' do
      expect {
        Pangea::Resources::Hetzner::Types::FloatingIpAttributes.new(
          home_location: "fsn1"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid type (must be ipv4 or ipv6)' do
      expect {
        Pangea::Resources::Hetzner::Types::FloatingIpAttributes.new(
          type: "ipv5"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts ipv4 type' do
      attrs = Pangea::Resources::Hetzner::Types::FloatingIpAttributes.new(type: "ipv4")
      expect(attrs.type).to eq("ipv4")
    end

    it 'accepts ipv6 type' do
      attrs = Pangea::Resources::Hetzner::Types::FloatingIpAttributes.new(type: "ipv6")
      expect(attrs.type).to eq("ipv6")
    end

    it 'defaults optional attributes to nil' do
      attrs = Pangea::Resources::Hetzner::Types::FloatingIpAttributes.new(type: "ipv4")
      expect(attrs.home_location).to be_nil
      expect(attrs.server_id).to be_nil
      expect(attrs.description).to be_nil
      expect(attrs.name).to be_nil
    end

    it 'defaults labels to empty hash' do
      attrs = Pangea::Resources::Hetzner::Types::FloatingIpAttributes.new(type: "ipv4")
      expect(attrs.labels).to eq({})
    end
  end
end
