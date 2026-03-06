# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/types'

module Pangea
  module Resources
    module Hetzner
      module Types
        # Hetzner DNS Zone attributes
        class ZoneAttributes < Pangea::Resources::BaseAttributes

          # Required attributes
          attribute :name, Resources::Types::String  # Domain name

          # Optional attributes
          attribute :ttl, Resources::Types::HetznerDnsZoneTtl.default(86400)
        end
      end
    end
  end
end
