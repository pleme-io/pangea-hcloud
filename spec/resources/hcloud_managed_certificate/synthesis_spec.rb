# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_managed_certificate/resource'
require 'pangea/resources/hcloud_managed_certificate/types'

RSpec.describe 'hcloud_managed_certificate synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes managed certificate' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_managed_certificate(:le_cert, {
          name: "letsencrypt-cert",
          domain_names: ["example.com", "www.example.com"]
        })
      end

      result = synthesizer.synthesis
      mc = result[:resource][:hcloud_managed_certificate][:le_cert]

      expect(mc[:name]).to eq("letsencrypt-cert")
      expect(mc[:domain_names]).to eq(["example.com", "www.example.com"])
    end

    it 'synthesizes managed certificate with single domain' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_managed_certificate(:single, {
          name: "single-domain-cert",
          domain_names: ["api.example.com"]
        })
      end

      result = synthesizer.synthesis
      mc = result[:resource][:hcloud_managed_certificate][:single]

      expect(mc[:domain_names]).to eq(["api.example.com"])
    end

    it 'synthesizes managed certificate with labels' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_managed_certificate(:labeled, {
          name: "labeled-cert",
          domain_names: ["example.com"],
          labels: { env: "production", service: "web" }
        })
      end

      result = synthesizer.synthesis
      mc = result[:resource][:hcloud_managed_certificate][:labeled]

      expect(mc[:labels][:env]).to eq("production")
      expect(mc[:labels][:service]).to eq("web")
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_managed_certificate(:test, {
          name: "test-cert",
          domain_names: ["test.example.com"]
        })
      end

      expect(ref.id).to eq("${hcloud_managed_certificate.test.id}")
      expect(ref.outputs[:domain_names]).to eq("${hcloud_managed_certificate.test.domain_names}")
      expect(ref.outputs[:certificate]).to eq("${hcloud_managed_certificate.test.certificate}")
    end

    it 'includes all expected output references' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_managed_certificate(:mc, {
          name: "mc",
          domain_names: ["example.com"]
        })
      end

      expect(ref.outputs).to include(:id, :name, :domain_names, :certificate)
    end
  end

  describe 'type validation' do
    it 'rejects missing required name' do
      expect {
        Pangea::Resources::Hetzner::Types::ManagedCertificateAttributes.new(
          domain_names: ["example.com"]
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required domain_names' do
      expect {
        Pangea::Resources::Hetzner::Types::ManagedCertificateAttributes.new(
          name: "test-cert"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'defaults labels to empty hash' do
      attrs = Pangea::Resources::Hetzner::Types::ManagedCertificateAttributes.new(
        name: "test", domain_names: ["example.com"]
      )
      expect(attrs.labels).to eq({})
    end
  end
end
