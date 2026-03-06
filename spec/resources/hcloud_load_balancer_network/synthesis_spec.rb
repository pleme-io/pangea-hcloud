# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_load_balancer_network/resource'
require 'pangea/resources/hcloud_load_balancer_network/types'

RSpec.describe 'hcloud_load_balancer_network synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes load balancer network attachment with IP' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer_network(:lb_network, {
          load_balancer_id: "${hcloud_load_balancer.app_lb.id}",
          network_id: "${hcloud_network.private.id}",
          ip: "10.0.1.5"
        })
      end

      result = synthesizer.synthesis
      lbn = result[:resource][:hcloud_load_balancer_network][:lb_network]

      expect(lbn[:load_balancer_id]).to eq("${hcloud_load_balancer.app_lb.id}")
      expect(lbn[:network_id]).to eq("${hcloud_network.private.id}")
      expect(lbn[:ip]).to eq("10.0.1.5")
    end

    it 'synthesizes with public interface disabled' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer_network(:private_only, {
          load_balancer_id: "lb-123",
          network_id: "net-456",
          enable_public_interface: false
        })
      end

      result = synthesizer.synthesis
      lbn = result[:resource][:hcloud_load_balancer_network][:private_only]

      expect(lbn[:enable_public_interface]).to be false
    end

    it 'defaults enable_public_interface to true' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer_network(:default, {
          load_balancer_id: "lb-123",
          network_id: "net-456"
        })
      end

      result = synthesizer.synthesis
      lbn = result[:resource][:hcloud_load_balancer_network][:default]

      expect(lbn[:enable_public_interface]).to be true
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer_network(:test, {
          load_balancer_id: "lb-123",
          network_id: "net-456"
        })
      end

      expect(ref.id).to eq("${hcloud_load_balancer_network.test.id}")
      expect(ref.outputs[:ip]).to eq("${hcloud_load_balancer_network.test.ip}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required load_balancer_id' do
      expect {
        Pangea::Resources::Hetzner::Types::LoadBalancerNetworkAttributes.new(
          network_id: "net-456"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required network_id' do
      expect {
        Pangea::Resources::Hetzner::Types::LoadBalancerNetworkAttributes.new(
          load_balancer_id: "lb-123"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'defaults ip to nil' do
      attrs = Pangea::Resources::Hetzner::Types::LoadBalancerNetworkAttributes.new(
        load_balancer_id: "lb-123", network_id: "net-456"
      )
      expect(attrs.ip).to be_nil
    end

    it 'defaults enable_public_interface to true' do
      attrs = Pangea::Resources::Hetzner::Types::LoadBalancerNetworkAttributes.new(
        load_balancer_id: "lb-123", network_id: "net-456"
      )
      expect(attrs.enable_public_interface).to be true
    end
  end
end
