# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/types'

module Pangea
  module Resources
    module Hetzner
      module Types
        # Hetzner Network Route attributes
        class NetworkRouteAttributes < Pangea::Resources::BaseAttributes

          # Required attributes
          attribute :network_id, Resources::Types::String
          attribute :destination, Resources::Types::CidrBlock
          attribute :gateway, Resources::Types::String
        end
      end
    end
  end
end
