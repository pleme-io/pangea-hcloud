# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_placement_group/resource'
require 'pangea/resources/hcloud_placement_group/types'

RSpec.describe 'hcloud_placement_group synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes placement group' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_placement_group(:spread, {
          name: "production-spread",
          type: "spread"
        })
      end

      result = synthesizer.synthesis
      pg = result[:resource][:hcloud_placement_group][:spread]

      expect(pg[:name]).to eq("production-spread")
      expect(pg[:type]).to eq("spread")
    end

    it 'synthesizes placement group with labels' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_placement_group(:labeled, {
          name: "labeled-spread",
          type: "spread",
          labels: { environment: "production", tier: "web" }
        })
      end

      result = synthesizer.synthesis
      pg = result[:resource][:hcloud_placement_group][:labeled]

      expect(pg[:labels][:environment]).to eq("production")
      expect(pg[:labels][:tier]).to eq("web")
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_placement_group(:test, {
          name: "test-pg",
          type: "spread"
        })
      end

      expect(ref.id).to eq("${hcloud_placement_group.test.id}")
      expect(ref.outputs[:name]).to eq("${hcloud_placement_group.test.name}")
      expect(ref.outputs[:type]).to eq("${hcloud_placement_group.test.type}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required name' do
      expect {
        Pangea::Resources::Hetzner::Types::PlacementGroupAttributes.new(
          type: "spread"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required type' do
      expect {
        Pangea::Resources::Hetzner::Types::PlacementGroupAttributes.new(
          name: "test-pg"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid placement group type' do
      expect {
        Pangea::Resources::Hetzner::Types::PlacementGroupAttributes.new(
          name: "test-pg", type: "cluster"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts spread type' do
      attrs = Pangea::Resources::Hetzner::Types::PlacementGroupAttributes.new(
        name: "test-pg", type: "spread"
      )
      expect(attrs.type).to eq("spread")
    end

    it 'defaults labels to empty hash' do
      attrs = Pangea::Resources::Hetzner::Types::PlacementGroupAttributes.new(
        name: "test-pg", type: "spread"
      )
      expect(attrs.labels).to eq({})
    end
  end
end
