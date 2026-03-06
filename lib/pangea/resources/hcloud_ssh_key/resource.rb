# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/hcloud_ssh_key/types'
require 'pangea/resource_registry'

module Pangea::Resources
  module HcloudSshKey
    include Pangea::Resources::ResourceBuilder

    define_resource :hcloud_ssh_key,
      attributes_class: Hetzner::Types::SshKeyAttributes,
      outputs: { id: :id, name: :name, fingerprint: :fingerprint, public_key: :public_key },
      map: [:name, :public_key] do |r, attrs|
        if attrs.labels.any?
          r.labels do
            attrs.labels.each { |k, v| public_send(k, v) }
          end
        end
      end
  end
  module Hetzner
    include HcloudSshKey
  end
end
Pangea::ResourceRegistry.register_module(Pangea::Resources::Hetzner)
