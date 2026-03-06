# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/types'

module Pangea
  module Resources
    module Hetzner
      module Types
        # Hetzner Floating IP Assignment attributes
        class FloatingIpAssignmentAttributes < Pangea::Resources::BaseAttributes

          # Required attributes
          attribute :floating_ip_id, Resources::Types::String
          attribute :server_id, Resources::Types::String
        end
      end
    end
  end
end
