# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_load_balancer_network/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudLoadBalancerNetwork
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_load_balancer_network,
      attributes_class: Hetzner::Types::LoadBalancerNetworkAttributes,
      outputs: { id: :id, load_balancer_id: :load_balancer_id, network_id: :network_id, ip: :ip },
      map: [:load_balancer_id, :network_id, :enable_public_interface],
      map_present: [:ip]
  end
  module Hetzner
    include HcloudLoadBalancerNetwork
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
