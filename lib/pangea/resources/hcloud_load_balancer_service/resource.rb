# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_load_balancer_service/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudLoadBalancerService
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_load_balancer_service,
      attributes_class: Hetzner::Types::LoadBalancerServiceAttributes,
      outputs: { id: :id, load_balancer_id: :load_balancer_id, protocol: :protocol, listen_port: :listen_port },
      map: [:load_balancer_id, :protocol, :proxyprotocol],
      map_present: [:listen_port, :destination_port] do |r, attrs|
        if attrs.http
          r.http do
            attrs.http.each do |key, value|
              public_send(key, value)
            end
          end
        end

        if attrs.health_check
          r.health_check do
            protocol attrs.health_check[:protocol] if attrs.health_check[:protocol]
            port attrs.health_check[:port] if attrs.health_check[:port]
            interval attrs.health_check[:interval] if attrs.health_check[:interval]
            timeout attrs.health_check[:timeout] if attrs.health_check[:timeout]
            retries attrs.health_check[:retries] if attrs.health_check[:retries]

            if attrs.health_check[:http]
              http do
                attrs.health_check[:http].each do |k, v|
                  public_send(k, v)
                end
              end
            end
          end
        end
      end
  end
  module Hetzner
    include HcloudLoadBalancerService
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
