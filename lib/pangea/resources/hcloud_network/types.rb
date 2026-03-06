# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/types'

module Pangea
  module Resources
    module Hetzner
      module Types
        # Hetzner Network resource attributes with validation
        class NetworkAttributes < Pangea::Resources::BaseAttributes

          # Required attributes
          attribute :name, Resources::Types::String
          attribute :ip_range, Resources::Types::CidrBlock

          # Optional attributes
          attribute :labels, Resources::Types::HetznerLabels.default({}.freeze)
        end
      end
    end
  end
end
