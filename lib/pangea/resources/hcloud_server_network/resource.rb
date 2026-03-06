# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_server_network/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudServerNetwork
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_server_network,
      attributes_class: Hetzner::Types::ServerNetworkAttributes,
      outputs: { id: :id, server_id: :server_id, network_id: :network_id, ip: :ip },
      map: [:server_id, :network_id],
      map_present: [:ip] do |r, attrs|
        r.alias_ips attrs.alias_ips if attrs.alias_ips.any?
      end
  end
  module Hetzner
    include HcloudServerNetwork
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
