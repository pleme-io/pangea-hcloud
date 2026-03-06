# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_ssh_key/resource'
require 'pangea/resources/hcloud_ssh_key/types'

RSpec.describe 'hcloud_ssh_key synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes minimal ssh key configuration' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_ssh_key(:deployer, {
          name: "deployer-key",
          public_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITest test@example.com"
        })
      end

      result = synthesizer.synthesis
      ssh_key = result[:resource][:hcloud_ssh_key][:deployer]

      expect(ssh_key[:name]).to eq("deployer-key")
      expect(ssh_key[:public_key]).to include("ssh-ed25519")
    end

    it 'synthesizes ssh key with labels' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_ssh_key(:deployer, {
          name: "deployer-key",
          public_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITest test@example.com",
          labels: {
            environment: "production",
            managed_by: "pangea"
          }
        })
      end

      result = synthesizer.synthesis
      ssh_key = result[:resource][:hcloud_ssh_key][:deployer]

      expect(ssh_key[:labels][:environment]).to eq("production")
      expect(ssh_key[:labels][:managed_by]).to eq("pangea")
    end

    it 'synthesizes ssh key with RSA public key' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_ssh_key(:rsa_key, {
          name: "rsa-key",
          public_key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... user@host"
        })
      end

      result = synthesizer.synthesis
      ssh_key = result[:resource][:hcloud_ssh_key][:rsa_key]

      expect(ssh_key[:public_key]).to include("ssh-rsa")
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_ssh_key(:test, {
          name: "test-key",
          public_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITest test@example.com"
        })
      end

      expect(ref.id).to eq("${hcloud_ssh_key.test.id}")
      expect(ref.outputs[:fingerprint]).to eq("${hcloud_ssh_key.test.fingerprint}")
      expect(ref.outputs[:name]).to eq("${hcloud_ssh_key.test.name}")
    end

    it 'includes all expected output references' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_ssh_key(:full, {
          name: "full-key",
          public_key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAITest test@example.com"
        })
      end

      expect(ref.outputs).to include(:id, :name, :fingerprint, :public_key)
    end
  end

  describe 'type validation' do
    it 'rejects missing required name' do
      expect {
        Pangea::Resources::Hetzner::Types::SshKeyAttributes.new(
          public_key: "ssh-ed25519 AAAA..."
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required public_key' do
      expect {
        Pangea::Resources::Hetzner::Types::SshKeyAttributes.new(
          name: "test-key"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'defaults labels to empty hash' do
      attrs = Pangea::Resources::Hetzner::Types::SshKeyAttributes.new(
        name: "test", public_key: "ssh-ed25519 AAAA..."
      )
      expect(attrs.labels).to eq({})
    end
  end
end
