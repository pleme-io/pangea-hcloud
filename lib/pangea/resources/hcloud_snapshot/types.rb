# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/types'

module Pangea
  module Resources
    module Hetzner
      module Types
        # Hetzner Snapshot attributes
        class SnapshotAttributes < Pangea::Resources::BaseAttributes

          # Required attributes
          attribute :server_id, Resources::Types::String

          # Optional attributes
          attribute :description, Resources::Types::String.optional.default(nil)
          attribute :labels, Resources::Types::HetznerLabels.default({}.freeze)
        end
      end
    end
  end
end
