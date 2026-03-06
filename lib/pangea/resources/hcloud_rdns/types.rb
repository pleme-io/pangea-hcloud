# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/types'

module Pangea
  module Resources
    module Hetzner
      module Types
        # Hetzner Reverse DNS attributes
        class RdnsAttributes < Pangea::Resources::BaseAttributes

          # Required attributes
          attribute :server_id, Resources::Types::String
          attribute :ip_address, Resources::Types::String
          attribute :dns_ptr, Resources::Types::String
        end
      end
    end
  end
end
