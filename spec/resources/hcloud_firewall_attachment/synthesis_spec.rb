# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_firewall_attachment/resource'
require 'pangea/resources/hcloud_firewall_attachment/types'

RSpec.describe 'hcloud_firewall_attachment synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes firewall attachment with server_ids' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_firewall_attachment(:web_fw_attach, {
          firewall_id: "${hcloud_firewall.web.id}",
          server_ids: ["${hcloud_server.web01.id}", "${hcloud_server.web02.id}"]
        })
      end

      result = synthesizer.synthesis
      fa = result[:resource][:hcloud_firewall_attachment][:web_fw_attach]

      expect(fa[:firewall_id]).to eq("${hcloud_firewall.web.id}")
    end

    it 'synthesizes firewall attachment with empty server_ids' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_firewall_attachment(:empty_attach, {
          firewall_id: "${hcloud_firewall.web.id}"
        })
      end

      result = synthesizer.synthesis
      fa = result[:resource][:hcloud_firewall_attachment][:empty_attach]

      expect(fa[:firewall_id]).to eq("${hcloud_firewall.web.id}")
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_firewall_attachment(:test, {
          firewall_id: "fw-123",
          server_ids: ["srv-1"]
        })
      end

      expect(ref.id).to eq("${hcloud_firewall_attachment.test.id}")
      expect(ref.outputs[:firewall_id]).to eq("${hcloud_firewall_attachment.test.firewall_id}")
      expect(ref.outputs[:server_ids]).to eq("${hcloud_firewall_attachment.test.server_ids}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required firewall_id' do
      expect {
        Pangea::Resources::Hetzner::Types::FirewallAttachmentAttributes.new(
          server_ids: ["srv-1"]
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'defaults server_ids to empty array' do
      attrs = Pangea::Resources::Hetzner::Types::FirewallAttachmentAttributes.new(
        firewall_id: "fw-123"
      )
      expect(attrs.server_ids).to eq([])
    end
  end
end
