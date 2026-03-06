# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_certificate/resource'
require 'pangea/resources/hcloud_certificate/types'

RSpec.describe 'hcloud_certificate synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes certificate with name only' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_certificate(:ssl_cert, {
          name: "ssl-certificate"
        })
      end

      result = synthesizer.synthesis
      cert = result[:resource][:hcloud_certificate][:ssl_cert]

      expect(cert[:name]).to eq("ssl-certificate")
    end

    it 'synthesizes certificate with PEM data' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_certificate(:full_cert, {
          name: "full-certificate",
          certificate: "-----BEGIN CERTIFICATE-----\n...",
          private_key: "-----BEGIN PRIVATE KEY-----\n..."
        })
      end

      result = synthesizer.synthesis
      cert = result[:resource][:hcloud_certificate][:full_cert]

      expect(cert[:name]).to eq("full-certificate")
      expect(cert[:certificate]).to include("BEGIN CERTIFICATE")
      expect(cert[:private_key]).to include("BEGIN PRIVATE KEY")
    end

    it 'synthesizes certificate with labels' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_certificate(:labeled, {
          name: "labeled-cert",
          labels: { domain: "example.com", env: "production" }
        })
      end

      result = synthesizer.synthesis
      cert = result[:resource][:hcloud_certificate][:labeled]

      expect(cert[:labels][:domain]).to eq("example.com")
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_certificate(:test, {
          name: "test-cert"
        })
      end

      expect(ref.id).to eq("${hcloud_certificate.test.id}")
      expect(ref.outputs[:name]).to eq("${hcloud_certificate.test.name}")
      expect(ref.outputs[:not_valid_before]).to eq("${hcloud_certificate.test.not_valid_before}")
      expect(ref.outputs[:not_valid_after]).to eq("${hcloud_certificate.test.not_valid_after}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required name' do
      expect {
        Pangea::Resources::Hetzner::Types::CertificateAttributes.new({})
      }.to raise_error(Dry::Struct::Error)
    end

    it 'defaults certificate to nil' do
      attrs = Pangea::Resources::Hetzner::Types::CertificateAttributes.new(name: "test")
      expect(attrs.certificate).to be_nil
    end

    it 'defaults private_key to nil' do
      attrs = Pangea::Resources::Hetzner::Types::CertificateAttributes.new(name: "test")
      expect(attrs.private_key).to be_nil
    end

    it 'defaults labels to empty hash' do
      attrs = Pangea::Resources::Hetzner::Types::CertificateAttributes.new(name: "test")
      expect(attrs.labels).to eq({})
    end
  end
end
