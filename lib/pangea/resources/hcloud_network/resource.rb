# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_network/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudNetwork
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_network,
      attributes_class: Hetzner::Types::NetworkAttributes,
      outputs: { id: :id, name: :name, ip_range: :ip_range },
      map: [:name, :ip_range] do |r, attrs|
        if attrs.labels.any?
          r.labels do
            attrs.labels.each { |k, v| public_send(k, v) }
          end
        end
      end
  end
  module Hetzner
    include HcloudNetwork
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
