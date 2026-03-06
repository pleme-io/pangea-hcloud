# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_load_balancer_target/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudLoadBalancerTarget
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_load_balancer_target,
      attributes_class: Hetzner::Types::LoadBalancerTargetAttributes,
      outputs: { id: :id, load_balancer_id: :load_balancer_id, type: :type, server_id: :server_id },
      map: [:load_balancer_id, :type, :use_private_ip],
      map_present: [:server_id, :label_selector, :ip]
  end
  module Hetzner
    include HcloudLoadBalancerTarget
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
