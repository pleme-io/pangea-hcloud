# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_floating_ip_assignment/resource'
require 'pangea/resources/hcloud_floating_ip_assignment/types'

RSpec.describe 'hcloud_floating_ip_assignment synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes floating IP assignment' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_floating_ip_assignment(:lb_ip_assign, {
          floating_ip_id: "${hcloud_floating_ip.lb_ip.id}",
          server_id: "${hcloud_server.lb.id}"
        })
      end

      result = synthesizer.synthesis
      fia = result[:resource][:hcloud_floating_ip_assignment][:lb_ip_assign]

      expect(fia[:floating_ip_id]).to eq("${hcloud_floating_ip.lb_ip.id}")
      expect(fia[:server_id]).to eq("${hcloud_server.lb.id}")
    end

    it 'synthesizes with literal IDs' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_floating_ip_assignment(:manual, {
          floating_ip_id: "12345",
          server_id: "67890"
        })
      end

      result = synthesizer.synthesis
      fia = result[:resource][:hcloud_floating_ip_assignment][:manual]

      expect(fia[:floating_ip_id]).to eq("12345")
      expect(fia[:server_id]).to eq("67890")
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_floating_ip_assignment(:test, {
          floating_ip_id: "fip-123",
          server_id: "srv-456"
        })
      end

      expect(ref.id).to eq("${hcloud_floating_ip_assignment.test.id}")
      expect(ref.outputs[:floating_ip_id]).to eq("${hcloud_floating_ip_assignment.test.floating_ip_id}")
      expect(ref.outputs[:server_id]).to eq("${hcloud_floating_ip_assignment.test.server_id}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required floating_ip_id' do
      expect {
        Pangea::Resources::Hetzner::Types::FloatingIpAssignmentAttributes.new(
          server_id: "srv-123"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required server_id' do
      expect {
        Pangea::Resources::Hetzner::Types::FloatingIpAssignmentAttributes.new(
          floating_ip_id: "fip-123"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts valid attributes' do
      attrs = Pangea::Resources::Hetzner::Types::FloatingIpAssignmentAttributes.new(
        floating_ip_id: "fip-123", server_id: "srv-456"
      )
      expect(attrs.floating_ip_id).to eq("fip-123")
      expect(attrs.server_id).to eq("srv-456")
    end
  end
end
