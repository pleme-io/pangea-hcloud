# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_firewall_attachment/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudFirewallAttachment
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_firewall_attachment,
      attributes_class: Hetzner::Types::FirewallAttachmentAttributes,
      outputs: { id: :id, firewall_id: :firewall_id, server_ids: :server_ids },
      map: [:firewall_id] do |r, attrs|
        r.server_ids attrs.server_ids if attrs.server_ids.any?
      end
  end
  module Hetzner
    include HcloudFirewallAttachment
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
