# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/types'

module Pangea
  module Resources
    module Hetzner
      module Types
        # Hetzner Placement Group attributes
        class PlacementGroupAttributes < Pangea::Resources::BaseAttributes

          # Required attributes
          attribute :name, Resources::Types::String
          attribute :type, Resources::Types::HetznerPlacementGroupType

          # Optional attributes
          attribute :labels, Resources::Types::HetznerLabels.default({}.freeze)
        end
      end
    end
  end
end
