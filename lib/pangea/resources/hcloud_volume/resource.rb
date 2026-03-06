# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_volume/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudVolume
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_volume,
      attributes_class: Hetzner::Types::VolumeAttributes,
      outputs: { id: :id, name: :name, size: :size, linux_device: :linux_device, location: :location },
      map: [:name, :size],
      map_present: [:location, :server_id] do |r, attrs|
        # format is a Kernel method — must call method_missing directly to bypass
        method_missing(:format, attrs.format) if attrs.format

        if attrs.labels.any?
          r.labels do
            attrs.labels.each { |k, v| public_send(k, v) }
          end
        end
      end
  end
  module Hetzner
    include HcloudVolume
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
