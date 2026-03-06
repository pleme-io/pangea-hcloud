# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_primary_ip/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudPrimaryIp
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_primary_ip,
      attributes_class: Hetzner::Types::PrimaryIpAttributes,
      outputs: { id: :id, ip_address: :ip_address, name: :name },
      map: [:name, :type, :assignee_type, :auto_delete],
      map_present: [:assignee_id, :datacenter] do |r, attrs|
        if attrs.labels.any?
          r.labels do
            attrs.labels.each { |k, v| public_send(k, v) }
          end
        end
      end
  end
  module Hetzner
    include HcloudPrimaryIp
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
