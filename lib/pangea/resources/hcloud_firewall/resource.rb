# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_firewall/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudFirewall
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_firewall,
      attributes_class: Hetzner::Types::FirewallAttributes,
      outputs: { id: :id, name: :name },
      map: [:name] do |r, attrs|
        attrs.rules.each do |rule|
          r.rule do
            direction rule[:direction]
            protocol rule[:protocol]
            port rule[:port] if rule[:port]
            source_ips rule[:source_ips] if rule[:source_ips]
            destination_ips rule[:destination_ips] if rule[:destination_ips]
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
    include HcloudFirewall
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
