# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_load_balancer/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudLoadBalancer
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_load_balancer,
      attributes_class: Hetzner::Types::LoadBalancerAttributes,
      outputs: { id: :id, name: :name, ipv4: :ipv4, ipv6: :ipv6 },
      map: [:name, :load_balancer_type],
      map_present: [:location, :network_zone] do |r, attrs|
        if attrs.algorithm
          r.algorithm do
            type attrs.algorithm[:type] if attrs.algorithm[:type]
          end
        end

        if attrs.labels.any?
          r.labels do
            attrs.labels.each { |k, v| public_send(k, v) }
          end
        end
      end
  end
  module Hetzner
    include HcloudLoadBalancer
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
