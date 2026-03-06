# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_zone_rrset/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudZoneRrset
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_zone_rrset,
      attributes_class: Hetzner::Types::ZoneRrsetAttributes,
      outputs: { id: :id, zone_id: :zone_id, name: :name, type: :type },
      map: [:zone_id, :name, :type, :values],
      map_present: [:ttl]
  end
  module Hetzner
    include HcloudZoneRrset
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
