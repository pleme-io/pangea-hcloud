# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_load_balancer_service/resource'
require 'pangea/resources/hcloud_load_balancer_service/types'

RSpec.describe 'hcloud_load_balancer_service synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes HTTP load balancer service' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer_service(:http, {
          load_balancer_id: "${hcloud_load_balancer.app_lb.id}",
          protocol: "http",
          listen_port: 80,
          destination_port: 80
        })
      end

      result = synthesizer.synthesis
      lbs = result[:resource][:hcloud_load_balancer_service][:http]

      expect(lbs[:protocol]).to eq("http")
      expect(lbs[:listen_port]).to eq(80)
    end

    it 'synthesizes HTTPS load balancer service' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer_service(:https, {
          load_balancer_id: "lb-123",
          protocol: "https",
          listen_port: 443,
          destination_port: 8080
        })
      end

      result = synthesizer.synthesis
      lbs = result[:resource][:hcloud_load_balancer_service][:https]

      expect(lbs[:protocol]).to eq("https")
      expect(lbs[:listen_port]).to eq(443)
      expect(lbs[:destination_port]).to eq(8080)
    end

    it 'synthesizes TCP load balancer service' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer_service(:tcp, {
          load_balancer_id: "lb-123",
          protocol: "tcp",
          listen_port: 5432,
          destination_port: 5432
        })
      end

      result = synthesizer.synthesis
      lbs = result[:resource][:hcloud_load_balancer_service][:tcp]

      expect(lbs[:protocol]).to eq("tcp")
    end

    it 'synthesizes service with proxyprotocol enabled' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer_service(:proxy, {
          load_balancer_id: "lb-123",
          protocol: "tcp",
          listen_port: 80,
          proxyprotocol: true
        })
      end

      result = synthesizer.synthesis
      lbs = result[:resource][:hcloud_load_balancer_service][:proxy]

      expect(lbs[:proxyprotocol]).to be true
    end

    it 'synthesizes service with health_check' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer_service(:health, {
          load_balancer_id: "lb-123",
          protocol: "http",
          listen_port: 80,
          health_check: {
            protocol: "http",
            port: 80,
            interval: 15,
            timeout: 10,
            retries: 3,
            http: {
              path: "/health",
              status_codes: "200"
            }
          }
        })
      end

      result = synthesizer.synthesis
      lbs = result[:resource][:hcloud_load_balancer_service][:health]

      expect(lbs[:health_check][:protocol]).to eq("http")
      expect(lbs[:health_check][:port]).to eq(80)
      expect(lbs[:health_check][:interval]).to eq(15)
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_load_balancer_service(:test, {
          load_balancer_id: "lb-123",
          protocol: "http"
        })
      end

      expect(ref.id).to eq("${hcloud_load_balancer_service.test.id}")
      expect(ref.outputs[:protocol]).to eq("${hcloud_load_balancer_service.test.protocol}")
      expect(ref.outputs[:listen_port]).to eq("${hcloud_load_balancer_service.test.listen_port}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required load_balancer_id' do
      expect {
        Pangea::Resources::Hetzner::Types::LoadBalancerServiceAttributes.new(
          protocol: "http"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required protocol' do
      expect {
        Pangea::Resources::Hetzner::Types::LoadBalancerServiceAttributes.new(
          load_balancer_id: "lb-123"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid protocol' do
      expect {
        Pangea::Resources::Hetzner::Types::LoadBalancerServiceAttributes.new(
          load_balancer_id: "lb-123", protocol: "ftp"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts all valid protocols' do
      %w[http https tcp].each do |proto|
        attrs = Pangea::Resources::Hetzner::Types::LoadBalancerServiceAttributes.new(
          load_balancer_id: "lb-123", protocol: proto
        )
        expect(attrs.protocol).to eq(proto)
      end
    end

    it 'defaults proxyprotocol to false' do
      attrs = Pangea::Resources::Hetzner::Types::LoadBalancerServiceAttributes.new(
        load_balancer_id: "lb-123", protocol: "http"
      )
      expect(attrs.proxyprotocol).to be false
    end

    it 'defaults optional attributes to nil' do
      attrs = Pangea::Resources::Hetzner::Types::LoadBalancerServiceAttributes.new(
        load_balancer_id: "lb-123", protocol: "http"
      )
      expect(attrs.listen_port).to be_nil
      expect(attrs.destination_port).to be_nil
      expect(attrs.http).to be_nil
      expect(attrs.health_check).to be_nil
    end
  end
end
