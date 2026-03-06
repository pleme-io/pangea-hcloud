# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_snapshot/resource'
require 'pangea/resources/hcloud_snapshot/types'

RSpec.describe 'hcloud_snapshot synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes snapshot with description and labels' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_snapshot(:backup, {
          server_id: "${hcloud_server.web01.id}",
          description: "Weekly backup",
          labels: { "type" => "backup" }
        })
      end

      result = synthesizer.synthesis
      snapshot = result[:resource][:hcloud_snapshot][:backup]

      expect(snapshot[:server_id]).to eq("${hcloud_server.web01.id}")
      expect(snapshot[:description]).to eq("Weekly backup")
      expect(snapshot[:labels]).to eq({ "type" => "backup" })
    end

    it 'synthesizes minimal snapshot (server_id only)' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_snapshot(:minimal, {
          server_id: "srv-123"
        })
      end

      result = synthesizer.synthesis
      snapshot = result[:resource][:hcloud_snapshot][:minimal]

      expect(snapshot[:server_id]).to eq("srv-123")
    end

    it 'synthesizes snapshot without description' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_snapshot(:no_desc, {
          server_id: "srv-123",
          labels: { "env" => "production" }
        })
      end

      result = synthesizer.synthesis
      snapshot = result[:resource][:hcloud_snapshot][:no_desc]

      expect(snapshot[:labels]).to eq({ "env" => "production" })
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_snapshot(:test, {
          server_id: "srv-123"
        })
      end

      expect(ref.id).to eq("${hcloud_snapshot.test.id}")
      expect(ref.outputs[:image_id]).to eq("${hcloud_snapshot.test.id}")
      expect(ref.outputs[:description]).to eq("${hcloud_snapshot.test.description}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required server_id' do
      expect {
        Pangea::Resources::Hetzner::Types::SnapshotAttributes.new(
          description: "test"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'defaults description to nil' do
      attrs = Pangea::Resources::Hetzner::Types::SnapshotAttributes.new(
        server_id: "srv-123"
      )
      expect(attrs.description).to be_nil
    end

    it 'defaults labels to empty hash' do
      attrs = Pangea::Resources::Hetzner::Types::SnapshotAttributes.new(
        server_id: "srv-123"
      )
      expect(attrs.labels).to eq({})
    end
  end
end
