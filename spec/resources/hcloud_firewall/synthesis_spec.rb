# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_firewall/resource'
require 'pangea/resources/hcloud_firewall/types'

RSpec.describe 'hcloud_firewall synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes basic firewall' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_firewall(:web, {
          name: "web-firewall",
          rules: [
            {
              direction: "in",
              protocol: "tcp",
              port: "80",
              source_ips: ["0.0.0.0/0"]
            }
          ]
        })
      end

      result = synthesizer.synthesis
      firewall = result[:resource][:hcloud_firewall][:web]

      expect(firewall[:name]).to eq("web-firewall")
    end

    it 'synthesizes firewall with labels' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_firewall(:web, {
          name: "web-firewall",
          labels: { environment: "production", service: "web" }
        })
      end

      result = synthesizer.synthesis
      firewall = result[:resource][:hcloud_firewall][:web]

      expect(firewall[:labels][:environment]).to eq("production")
      expect(firewall[:labels][:service]).to eq("web")
    end

    it 'synthesizes firewall with name only (no rules)' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_firewall(:empty, {
          name: "empty-firewall"
        })
      end

      result = synthesizer.synthesis
      firewall = result[:resource][:hcloud_firewall][:empty]

      expect(firewall[:name]).to eq("empty-firewall")
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_firewall(:test, {
          name: "test-firewall"
        })
      end

      expect(ref.id).to eq("${hcloud_firewall.test.id}")
      expect(ref.outputs[:name]).to eq("${hcloud_firewall.test.name}")
    end

    it 'includes all expected output references' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_firewall(:fw, {
          name: "fw"
        })
      end

      expect(ref.outputs).to include(:id, :name)
    end
  end

  describe 'type validation' do
    it 'rejects missing required name' do
      expect {
        Pangea::Resources::Hetzner::Types::FirewallAttributes.new({})
      }.to raise_error(Dry::Struct::Error)
    end

    it 'defaults rules to empty array' do
      attrs = Pangea::Resources::Hetzner::Types::FirewallAttributes.new(name: "test")
      expect(attrs.rules).to eq([])
    end

    it 'defaults labels to empty hash' do
      attrs = Pangea::Resources::Hetzner::Types::FirewallAttributes.new(name: "test")
      expect(attrs.labels).to eq({})
    end
  end
end
