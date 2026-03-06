# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_floating_ip/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudFloatingIp
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_floating_ip,
      attributes_class: Hetzner::Types::FloatingIpAttributes,
      outputs: { id: :id, ip_address: :ip_address, name: :name, home_location: :home_location },
      map: [:type],
      map_present: [:home_location, :server_id, :description, :name] do |r, attrs|
        if attrs.labels.any?
          r.labels do
            attrs.labels.each { |k, v| public_send(k, v) }
          end
        end
      end
  end
  module Hetzner
    include HcloudFloatingIp
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
