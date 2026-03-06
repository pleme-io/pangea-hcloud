# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_uploaded_certificate/resource'
require 'pangea/resources/hcloud_uploaded_certificate/types'

RSpec.describe 'hcloud_uploaded_certificate synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  let(:valid_cert) { "-----BEGIN CERTIFICATE-----\nMIIC...\n-----END CERTIFICATE-----" }
  let(:valid_key) { "-----BEGIN PRIVATE KEY-----\nMIIE...\n-----END PRIVATE KEY-----" }
  let(:valid_rsa_key) { "-----BEGIN RSA PRIVATE KEY-----\nMIIE...\n-----END RSA PRIVATE KEY-----" }
  let(:valid_ec_key) { "-----BEGIN EC PRIVATE KEY-----\nMIIE...\n-----END EC PRIVATE KEY-----" }

  describe 'terraform synthesis' do
    it 'synthesizes uploaded certificate' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_uploaded_certificate(:ssl_cert, {
          name: "example.com-ssl",
          certificate: "-----BEGIN CERTIFICATE-----\nMIIC...\n-----END CERTIFICATE-----",
          private_key: "-----BEGIN PRIVATE KEY-----\nMIIE...\n-----END PRIVATE KEY-----",
          labels: { "env" => "production" }
        })
      end

      result = synthesizer.synthesis
      cert = result[:resource][:hcloud_uploaded_certificate][:ssl_cert]

      expect(cert[:name]).to eq("example.com-ssl")
      expect(cert[:certificate]).to include("BEGIN CERTIFICATE")
      expect(cert[:private_key]).to include("BEGIN PRIVATE KEY")
      expect(cert[:labels]).to eq({ "env" => "production" })
    end

    it 'synthesizes certificate without labels' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_uploaded_certificate(:no_labels, {
          name: "no-labels-cert",
          certificate: "-----BEGIN CERTIFICATE-----\nMIIC...\n-----END CERTIFICATE-----",
          private_key: "-----BEGIN PRIVATE KEY-----\nMIIE...\n-----END PRIVATE KEY-----"
        })
      end

      result = synthesizer.synthesis
      cert = result[:resource][:hcloud_uploaded_certificate][:no_labels]

      expect(cert[:name]).to eq("no-labels-cert")
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_uploaded_certificate(:test, {
          name: "test-cert",
          certificate: "-----BEGIN CERTIFICATE-----\nMIIC...\n-----END CERTIFICATE-----",
          private_key: "-----BEGIN PRIVATE KEY-----\nMIIE...\n-----END PRIVATE KEY-----"
        })
      end

      expect(ref.id).to eq("${hcloud_uploaded_certificate.test.id}")
      expect(ref.outputs[:fingerprint]).to eq("${hcloud_uploaded_certificate.test.fingerprint}")
      expect(ref.outputs[:not_valid_before]).to eq("${hcloud_uploaded_certificate.test.not_valid_before}")
      expect(ref.outputs[:not_valid_after]).to eq("${hcloud_uploaded_certificate.test.not_valid_after}")
    end

    it 'includes all expected output references' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_uploaded_certificate(:full, {
          name: "full",
          certificate: "-----BEGIN CERTIFICATE-----\nMIIC...\n-----END CERTIFICATE-----",
          private_key: "-----BEGIN PRIVATE KEY-----\nMIIE...\n-----END PRIVATE KEY-----"
        })
      end

      expect(ref.outputs).to include(:id, :name, :not_valid_before, :not_valid_after, :fingerprint)
    end
  end

  describe 'type validation' do
    it 'rejects missing required name' do
      expect {
        Pangea::Resources::Hetzner::Types::UploadedCertificateAttributes.new(
          certificate: valid_cert, private_key: valid_key
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required certificate' do
      expect {
        Pangea::Resources::Hetzner::Types::UploadedCertificateAttributes.new(
          name: "test", private_key: valid_key
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required private_key' do
      expect {
        Pangea::Resources::Hetzner::Types::UploadedCertificateAttributes.new(
          name: "test", certificate: valid_cert
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid PEM certificate format' do
      expect {
        Pangea::Resources::Hetzner::Types::UploadedCertificateAttributes.new(
          name: "test", certificate: "not-pem-data", private_key: valid_key
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid PEM private key format' do
      expect {
        Pangea::Resources::Hetzner::Types::UploadedCertificateAttributes.new(
          name: "test", certificate: valid_cert, private_key: "not-pem-data"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts RSA private key format' do
      attrs = Pangea::Resources::Hetzner::Types::UploadedCertificateAttributes.new(
        name: "test", certificate: valid_cert, private_key: valid_rsa_key
      )
      expect(attrs.private_key).to include("RSA PRIVATE KEY")
    end

    it 'accepts EC private key format' do
      attrs = Pangea::Resources::Hetzner::Types::UploadedCertificateAttributes.new(
        name: "test", certificate: valid_cert, private_key: valid_ec_key
      )
      expect(attrs.private_key).to include("EC PRIVATE KEY")
    end

    it 'defaults labels to empty hash' do
      attrs = Pangea::Resources::Hetzner::Types::UploadedCertificateAttributes.new(
        name: "test", certificate: valid_cert, private_key: valid_key
      )
      expect(attrs.labels).to eq({})
    end
  end
end
