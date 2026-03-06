# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/types'

module Pangea
  module Resources
    module Hetzner
      module Types
        # Hetzner Managed Certificate attributes
        class ManagedCertificateAttributes < Pangea::Resources::BaseAttributes

          # Required attributes
          attribute :name, Resources::Types::String
          attribute :domain_names, Resources::Types::Array.of(Resources::Types::String)

          # Optional attributes
          attribute :labels, Resources::Types::HetznerLabels.default({}.freeze)
        end
      end
    end
  end
end
