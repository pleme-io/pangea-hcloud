# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_server/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudServer
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_server,
      attributes_class: Hetzner::Types::ServerAttributes,
      outputs: {
        id: :id, name: :name, ipv4_address: :ipv4_address, ipv6_address: :ipv6_address,
        ipv6_network: :ipv6_network, status: :status, backup_window: :backup_window, datacenter: :datacenter
      },
      map: [:name, :server_type, :image, :backups],
      map_present: [:location, :datacenter, :user_data, :iso, :placement_group_id] do |r, attrs|
        # Arrays with .any? guard
        r.ssh_keys attrs.ssh_keys if attrs.ssh_keys.any?
        r.firewall_ids attrs.firewall_ids if attrs.firewall_ids.any?

        # rescue is a Ruby keyword — must use send
        r.send(:rescue, attrs.rescue) if attrs.rescue

        # Nested block for public network configuration
        if attrs.public_net
          r.public_net do
            ipv4_enabled attrs.public_net[:ipv4_enabled] if attrs.public_net.key?(:ipv4_enabled)
            ipv6_enabled attrs.public_net[:ipv6_enabled] if attrs.public_net.key?(:ipv6_enabled)
            ipv4 attrs.public_net[:ipv4] if attrs.public_net[:ipv4]
            ipv6 attrs.public_net[:ipv6] if attrs.public_net[:ipv6]
          end
        end

        # Nested block for private network configuration
        if attrs.network
          r.network do
            network_id attrs.network[:network_id] if attrs.network[:network_id]
            ip attrs.network[:ip] if attrs.network[:ip]
            alias_ips attrs.network[:alias_ips] if attrs.network[:alias_ips]
          end
        end

        # Labels (HetznerLabels type stringifies keys — use nested block for symbol-keyed output)
        if attrs.labels.any?
          r.labels do
            attrs.labels.each { |k, v| public_send(k, v) }
          end
        end
      end
  end
  module Hetzner
    include HcloudServer
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
