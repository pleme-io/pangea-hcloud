# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/types'

module Pangea
  module Resources
    module Hetzner
      module Types
        # Hetzner Firewall Attachment attributes
        class FirewallAttachmentAttributes < Pangea::Resources::BaseAttributes

          # Required attributes
          attribute :firewall_id, Resources::Types::String
          attribute :server_ids, Resources::Types::Array.of(Resources::Types::String).default([].freeze)
        end
      end
    end
  end
end
