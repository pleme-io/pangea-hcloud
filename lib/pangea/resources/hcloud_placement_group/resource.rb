# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_placement_group/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudPlacementGroup
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_placement_group,
      attributes_class: Hetzner::Types::PlacementGroupAttributes,
      outputs: { id: :id, name: :name, type: :type },
      map: [:name, :type] do |r, attrs|
        if attrs.labels.any?
          r.labels do
            attrs.labels.each { |k, v| public_send(k, v) }
          end
        end
      end
  end
  module Hetzner
    include HcloudPlacementGroup
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
