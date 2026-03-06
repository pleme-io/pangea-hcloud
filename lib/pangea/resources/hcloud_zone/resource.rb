# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_zone/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudZone
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_zone,
      attributes_class: Hetzner::Types::ZoneAttributes,
      outputs: { id: :id, name: :name, ttl: :ttl },
      map: [:name, :ttl]
  end
  module Hetzner
    include HcloudZone
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
