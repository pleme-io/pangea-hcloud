# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_network_subnet/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudNetworkSubnet
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_network_subnet,
      attributes_class: Hetzner::Types::NetworkSubnetAttributes,
      outputs: { id: :id, network_id: :network_id, ip_range: :ip_range, gateway: :gateway },
      map: [:network_id, :type, :network_zone, :ip_range],
      map_present: [:vswitch_id]
  end
  module Hetzner
    include HcloudNetworkSubnet
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
