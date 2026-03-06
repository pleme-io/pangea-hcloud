# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_snapshot/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudSnapshot
    include Pangea::Resources::ResourceBuilder

    # labels set unconditionally (no .any? guard in original code)
    # image_id output maps to :id terraform attribute
    define_resource :hcloud_snapshot,
      attributes_class: Hetzner::Types::SnapshotAttributes,
      outputs: { id: :id, image_id: :id, description: :description },
      map: [:server_id, :labels],
      map_present: [:description]
  end
  module Hetzner
    include HcloudSnapshot
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
