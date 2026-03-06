# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_volume_attachment/resource'
require 'pangea/resources/hcloud_volume_attachment/types'

RSpec.describe 'hcloud_volume_attachment synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes volume attachment with automount' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_volume_attachment(:data_attach, {
          volume_id: "${hcloud_volume.data.id}",
          server_id: "${hcloud_server.web.id}",
          automount: true
        })
      end

      result = synthesizer.synthesis
      va = result[:resource][:hcloud_volume_attachment][:data_attach]

      expect(va[:volume_id]).to eq("${hcloud_volume.data.id}")
      expect(va[:server_id]).to eq("${hcloud_server.web.id}")
      expect(va[:automount]).to be true
    end

    it 'synthesizes volume attachment without automount' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_volume_attachment(:manual_attach, {
          volume_id: "${hcloud_volume.data.id}",
          server_id: "${hcloud_server.web.id}"
        })
      end

      result = synthesizer.synthesis
      va = result[:resource][:hcloud_volume_attachment][:manual_attach]

      expect(va[:automount]).to be false
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_volume_attachment(:test, {
          volume_id: "vol-123",
          server_id: "srv-456"
        })
      end

      expect(ref.id).to eq("${hcloud_volume_attachment.test.id}")
      expect(ref.outputs[:volume_id]).to eq("${hcloud_volume_attachment.test.volume_id}")
      expect(ref.outputs[:server_id]).to eq("${hcloud_volume_attachment.test.server_id}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required volume_id' do
      expect {
        Pangea::Resources::Hetzner::Types::VolumeAttachmentAttributes.new(
          server_id: "srv-123"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required server_id' do
      expect {
        Pangea::Resources::Hetzner::Types::VolumeAttachmentAttributes.new(
          volume_id: "vol-123"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'defaults automount to false' do
      attrs = Pangea::Resources::Hetzner::Types::VolumeAttachmentAttributes.new(
        volume_id: "vol-123", server_id: "srv-456"
      )
      expect(attrs.automount).to be false
    end
  end
end
