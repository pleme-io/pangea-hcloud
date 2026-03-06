# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/types'

module Pangea
  module Resources
    module Hetzner
      module Types
        # Hetzner Uploaded Certificate attributes
        class UploadedCertificateAttributes < Pangea::Resources::BaseAttributes

          # Required attributes
          attribute :name, Resources::Types::String
          attribute :certificate, Resources::Types::HetznerPemCertificate
          attribute :private_key, Resources::Types::HetznerPemPrivateKey

          # Optional attributes
          attribute :labels, Resources::Types::HetznerLabels.default({}.freeze)
        end
      end
    end
  end
end
