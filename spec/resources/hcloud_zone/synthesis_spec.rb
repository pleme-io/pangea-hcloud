# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_zone/resource'
require 'pangea/resources/hcloud_zone/types'

RSpec.describe 'hcloud_zone synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes DNS zone with custom TTL' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_zone(:primary_zone, {
          name: "example.com",
          ttl: 3600
        })
      end

      result = synthesizer.synthesis
      zone = result[:resource][:hcloud_zone][:primary_zone]

      expect(zone[:name]).to eq("example.com")
      expect(zone[:ttl]).to eq(3600)
    end

    it 'synthesizes DNS zone with default TTL' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_zone(:default_ttl, {
          name: "default.example.com"
        })
      end

      result = synthesizer.synthesis
      zone = result[:resource][:hcloud_zone][:default_ttl]

      expect(zone[:name]).to eq("default.example.com")
      expect(zone[:ttl]).to eq(86400)
    end

    it 'synthesizes zone with minimum TTL' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_zone(:min_ttl, {
          name: "fast.example.com",
          ttl: 60
        })
      end

      result = synthesizer.synthesis
      zone = result[:resource][:hcloud_zone][:min_ttl]

      expect(zone[:ttl]).to eq(60)
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_zone(:test, {
          name: "test.example.com"
        })
      end

      expect(ref.id).to eq("${hcloud_zone.test.id}")
      expect(ref.outputs[:name]).to eq("${hcloud_zone.test.name}")
      expect(ref.outputs[:ttl]).to eq("${hcloud_zone.test.ttl}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required name' do
      expect {
        Pangea::Resources::Hetzner::Types::ZoneAttributes.new({})
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects TTL below minimum (60)' do
      expect {
        Pangea::Resources::Hetzner::Types::ZoneAttributes.new(
          name: "test.com", ttl: 30
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects TTL above maximum (86400)' do
      expect {
        Pangea::Resources::Hetzner::Types::ZoneAttributes.new(
          name: "test.com", ttl: 100000
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts minimum TTL boundary (60)' do
      attrs = Pangea::Resources::Hetzner::Types::ZoneAttributes.new(
        name: "test.com", ttl: 60
      )
      expect(attrs.ttl).to eq(60)
    end

    it 'accepts maximum TTL boundary (86400)' do
      attrs = Pangea::Resources::Hetzner::Types::ZoneAttributes.new(
        name: "test.com", ttl: 86400
      )
      expect(attrs.ttl).to eq(86400)
    end

    it 'defaults TTL to 86400' do
      attrs = Pangea::Resources::Hetzner::Types::ZoneAttributes.new(name: "test.com")
      expect(attrs.ttl).to eq(86400)
    end
  end
end
