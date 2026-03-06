# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_volume/resource'
require 'pangea/resources/hcloud_volume/types'

RSpec.describe 'hcloud_volume synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes volume with location and format' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_volume(:data, {
          name: "web-data",
          size: 100,
          location: "fsn1",
          format: "ext4"
        })
      end

      result = synthesizer.synthesis
      volume = result[:resource][:hcloud_volume][:data]

      expect(volume[:name]).to eq("web-data")
      expect(volume[:size]).to eq(100)
      expect(volume[:location]).to eq("fsn1")
      expect(volume[:format]).to eq("ext4")
    end

    it 'synthesizes volume with server_id instead of location' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_volume(:data, {
          name: "server-data",
          size: 50,
          server_id: "${hcloud_server.web.id}"
        })
      end

      result = synthesizer.synthesis
      volume = result[:resource][:hcloud_volume][:data]

      expect(volume[:name]).to eq("server-data")
      expect(volume[:server_id]).to eq("${hcloud_server.web.id}")
    end

    it 'synthesizes volume with labels' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_volume(:data, {
          name: "labeled-data",
          size: 100,
          location: "fsn1",
          labels: { purpose: "database", tier: "production" }
        })
      end

      result = synthesizer.synthesis
      volume = result[:resource][:hcloud_volume][:data]

      expect(volume[:labels][:purpose]).to eq("database")
      expect(volume[:labels][:tier]).to eq("production")
    end

    it 'synthesizes volume with xfs format' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_volume(:xfs_vol, {
          name: "xfs-volume",
          size: 200,
          location: "nbg1",
          format: "xfs"
        })
      end

      result = synthesizer.synthesis
      volume = result[:resource][:hcloud_volume][:xfs_vol]

      expect(volume[:format]).to eq("xfs")
    end

    it 'synthesizes minimal volume (name and size only)' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_volume(:minimal, {
          name: "minimal-vol",
          size: 10
        })
      end

      result = synthesizer.synthesis
      volume = result[:resource][:hcloud_volume][:minimal]

      expect(volume[:name]).to eq("minimal-vol")
      expect(volume[:size]).to eq(10)
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_volume(:test, {
          name: "test-vol",
          size: 50,
          location: "fsn1"
        })
      end

      expect(ref.id).to eq("${hcloud_volume.test.id}")
      expect(ref.outputs[:linux_device]).to eq("${hcloud_volume.test.linux_device}")
      expect(ref.outputs[:location]).to eq("${hcloud_volume.test.location}")
    end

    it 'includes all expected output references' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_volume(:vol, {
          name: "vol",
          size: 10,
          location: "fsn1"
        })
      end

      expect(ref.outputs).to include(:id, :name, :size, :linux_device, :location)
    end
  end

  describe 'type validation' do
    it 'rejects missing required name' do
      expect {
        Pangea::Resources::Hetzner::Types::VolumeAttributes.new(size: 50)
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required size' do
      expect {
        Pangea::Resources::Hetzner::Types::VolumeAttributes.new(name: "test")
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects size below minimum (10 GB)' do
      expect {
        Pangea::Resources::Hetzner::Types::VolumeAttributes.new(
          name: "test", size: 5
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects size above maximum (10000 GB)' do
      expect {
        Pangea::Resources::Hetzner::Types::VolumeAttributes.new(
          name: "test", size: 10001
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts minimum size boundary (10 GB)' do
      attrs = Pangea::Resources::Hetzner::Types::VolumeAttributes.new(
        name: "test", size: 10
      )
      expect(attrs.size).to eq(10)
    end

    it 'accepts maximum size boundary (10000 GB)' do
      attrs = Pangea::Resources::Hetzner::Types::VolumeAttributes.new(
        name: "test", size: 10000
      )
      expect(attrs.size).to eq(10000)
    end

    it 'rejects invalid volume format' do
      expect {
        Pangea::Resources::Hetzner::Types::VolumeAttributes.new(
          name: "test", size: 50, format: "ntfs"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts ext4 format' do
      attrs = Pangea::Resources::Hetzner::Types::VolumeAttributes.new(
        name: "test", size: 50, format: "ext4"
      )
      expect(attrs.format).to eq("ext4")
    end

    it 'accepts xfs format' do
      attrs = Pangea::Resources::Hetzner::Types::VolumeAttributes.new(
        name: "test", size: 50, format: "xfs"
      )
      expect(attrs.format).to eq("xfs")
    end

    it 'rejects invalid location' do
      expect {
        Pangea::Resources::Hetzner::Types::VolumeAttributes.new(
          name: "test", size: 50, location: "invalid"
        )
      }.to raise_error(Dry::Struct::Error)
    end
  end

  describe 'default values' do
    it 'defaults location to nil' do
      attrs = Pangea::Resources::Hetzner::Types::VolumeAttributes.new(
        name: "test", size: 50
      )
      expect(attrs.location).to be_nil
    end

    it 'defaults format to nil' do
      attrs = Pangea::Resources::Hetzner::Types::VolumeAttributes.new(
        name: "test", size: 50
      )
      expect(attrs.format).to be_nil
    end

    it 'defaults server_id to nil' do
      attrs = Pangea::Resources::Hetzner::Types::VolumeAttributes.new(
        name: "test", size: 50
      )
      expect(attrs.server_id).to be_nil
    end

    it 'defaults labels to empty hash' do
      attrs = Pangea::Resources::Hetzner::Types::VolumeAttributes.new(
        name: "test", size: 50
      )
      expect(attrs.labels).to eq({})
    end
  end
end
