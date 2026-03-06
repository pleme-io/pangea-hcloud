# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_rdns/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudRdns
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_rdns,
      attributes_class: Hetzner::Types::RdnsAttributes,
      outputs: { id: :id, server_id: :server_id, ip_address: :ip_address, dns_ptr: :dns_ptr },
      map: [:server_id, :ip_address, :dns_ptr]
  end
  module Hetzner
    include HcloudRdns
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
