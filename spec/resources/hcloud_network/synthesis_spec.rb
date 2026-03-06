# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_network/resource'
require 'pangea/resources/hcloud_network/types'

RSpec.describe 'hcloud_network synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes basic network' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_network(:private, {
          name: "private-network",
          ip_range: "10.0.0.0/16"
        })
      end

      result = synthesizer.synthesis
      network = result[:resource][:hcloud_network][:private]

      expect(network[:name]).to eq("private-network")
      expect(network[:ip_range]).to eq("10.0.0.0/16")
    end

    it 'synthesizes network with labels' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_network(:private, {
          name: "private-network",
          ip_range: "10.0.0.0/16",
          labels: { environment: "production" }
        })
      end

      result = synthesizer.synthesis
      network = result[:resource][:hcloud_network][:private]

      expect(network[:labels][:environment]).to eq("production")
    end

    it 'synthesizes network without labels when empty' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_network(:minimal, {
          name: "minimal-network",
          ip_range: "172.16.0.0/12"
        })
      end

      result = synthesizer.synthesis
      network = result[:resource][:hcloud_network][:minimal]

      expect(network[:name]).to eq("minimal-network")
      expect(network[:ip_range]).to eq("172.16.0.0/12")
    end

    it 'synthesizes network with multiple labels' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_network(:tagged, {
          name: "tagged-network",
          ip_range: "10.0.0.0/8",
          labels: { environment: "staging", team: "platform", managed_by: "pangea" }
        })
      end

      result = synthesizer.synthesis
      network = result[:resource][:hcloud_network][:tagged]

      expect(network[:labels][:environment]).to eq("staging")
      expect(network[:labels][:team]).to eq("platform")
      expect(network[:labels][:managed_by]).to eq("pangea")
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_network(:test, {
          name: "test-network",
          ip_range: "10.0.0.0/16"
        })
      end

      expect(ref.id).to eq("${hcloud_network.test.id}")
      expect(ref.outputs[:name]).to eq("${hcloud_network.test.name}")
      expect(ref.outputs[:ip_range]).to eq("${hcloud_network.test.ip_range}")
    end

    it 'includes all expected output references' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_network(:net, {
          name: "net",
          ip_range: "10.0.0.0/16"
        })
      end

      expect(ref.outputs).to include(:id, :name, :ip_range)
    end
  end

  describe 'type validation' do
    it 'rejects missing required name' do
      expect {
        Pangea::Resources::Hetzner::Types::NetworkAttributes.new(
          ip_range: "10.0.0.0/16"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required ip_range' do
      expect {
        Pangea::Resources::Hetzner::Types::NetworkAttributes.new(
          name: "test-network"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid CIDR block format' do
      expect {
        Pangea::Resources::Hetzner::Types::NetworkAttributes.new(
          name: "test-network",
          ip_range: "not-a-cidr"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects CIDR without prefix length' do
      expect {
        Pangea::Resources::Hetzner::Types::NetworkAttributes.new(
          name: "test-network",
          ip_range: "10.0.0.0"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts valid CIDR blocks' do
      %w[10.0.0.0/16 192.168.0.0/24 172.16.0.0/12 10.0.0.0/8].each do |cidr|
        attrs = Pangea::Resources::Hetzner::Types::NetworkAttributes.new(
          name: "test", ip_range: cidr
        )
        expect(attrs.ip_range).to eq(cidr)
      end
    end
  end

  describe 'default values' do
    it 'defaults labels to empty hash' do
      attrs = Pangea::Resources::Hetzner::Types::NetworkAttributes.new(
        name: "test", ip_range: "10.0.0.0/16"
      )
      expect(attrs.labels).to eq({})
    end
  end
end
