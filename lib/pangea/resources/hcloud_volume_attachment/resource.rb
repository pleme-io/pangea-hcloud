# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_volume_attachment/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudVolumeAttachment
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_volume_attachment,
      attributes_class: Hetzner::Types::VolumeAttachmentAttributes,
      outputs: { id: :id, volume_id: :volume_id, server_id: :server_id },
      map: [:volume_id, :server_id, :automount]
  end
  module Hetzner
    include HcloudVolumeAttachment
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
