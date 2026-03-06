# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_certificate/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudCertificate
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_certificate,
      attributes_class: Hetzner::Types::CertificateAttributes,
      outputs: { id: :id, name: :name, not_valid_before: :not_valid_before, not_valid_after: :not_valid_after },
      map: [:name],
      map_present: [:certificate, :private_key] do |r, attrs|
        if attrs.labels.any?
          r.labels do
            attrs.labels.each { |k, v| public_send(k, v) }
          end
        end
      end
  end
  module Hetzner
    include HcloudCertificate
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
