# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_floating_ip_assignment/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudFloatingIpAssignment
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_floating_ip_assignment,
      attributes_class: Hetzner::Types::FloatingIpAssignmentAttributes,
      outputs: { id: :id, floating_ip_id: :floating_ip_id, server_id: :server_id },
      map: [:floating_ip_id, :server_id]
  end
  module Hetzner
    include HcloudFloatingIpAssignment
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
