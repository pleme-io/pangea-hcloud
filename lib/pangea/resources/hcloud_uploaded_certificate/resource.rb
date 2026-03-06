# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_uploaded_certificate/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudUploadedCertificate
    include Pangea::Resources::ResourceBuilder

    # labels set unconditionally (no .any? guard in original code)
    define_resource :hcloud_uploaded_certificate,
      attributes_class: Hetzner::Types::UploadedCertificateAttributes,
      outputs: { id: :id, name: :name, not_valid_before: :not_valid_before, not_valid_after: :not_valid_after, fingerprint: :fingerprint },
      map: [:name, :certificate, :private_key, :labels]
  end
  module Hetzner
    include HcloudUploadedCertificate
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
