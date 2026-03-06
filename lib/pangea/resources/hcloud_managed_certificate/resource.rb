# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_managed_certificate/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudManagedCertificate
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_managed_certificate,
      attributes_class: Hetzner::Types::ManagedCertificateAttributes,
      outputs: { id: :id, name: :name, domain_names: :domain_names, certificate: :certificate },
      map: [:name, :domain_names] do |r, attrs|
        if attrs.labels.any?
          r.labels do
            attrs.labels.each { |k, v| public_send(k, v) }
          end
        end
      end
  end
  module Hetzner
    include HcloudManagedCertificate
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
