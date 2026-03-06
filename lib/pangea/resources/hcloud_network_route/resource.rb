# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_network_route/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudNetworkRoute
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_network_route,
      attributes_class: Hetzner::Types::NetworkRouteAttributes,
      outputs: { id: :id, network_id: :network_id, destination: :destination, gateway: :gateway },
      map: [:network_id, :destination, :gateway]
  end
  module Hetzner
    include HcloudNetworkRoute
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
