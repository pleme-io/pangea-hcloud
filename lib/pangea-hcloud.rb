# frozen_string_literal: true

require 'pangea'
require 'terraform-synthesizer'

# Hetzner types
require_relative 'pangea/resources/types/hetzner/core'

# Hetzner Cloud resources
require_relative 'pangea/resources/hcloud_certificate/resource'
require_relative 'pangea/resources/hcloud_firewall/resource'
require_relative 'pangea/resources/hcloud_firewall_attachment/resource'
require_relative 'pangea/resources/hcloud_floating_ip/resource'
require_relative 'pangea/resources/hcloud_floating_ip_assignment/resource'
require_relative 'pangea/resources/hcloud_load_balancer/resource'
require_relative 'pangea/resources/hcloud_load_balancer_network/resource'
require_relative 'pangea/resources/hcloud_load_balancer_service/resource'
require_relative 'pangea/resources/hcloud_load_balancer_target/resource'
require_relative 'pangea/resources/hcloud_managed_certificate/resource'
require_relative 'pangea/resources/hcloud_network/resource'
require_relative 'pangea/resources/hcloud_network_route/resource'
require_relative 'pangea/resources/hcloud_network_subnet/resource'
require_relative 'pangea/resources/hcloud_placement_group/resource'
require_relative 'pangea/resources/hcloud_primary_ip/resource'
require_relative 'pangea/resources/hcloud_rdns/resource'
require_relative 'pangea/resources/hcloud_server/resource'
require_relative 'pangea/resources/hcloud_server_network/resource'
require_relative 'pangea/resources/hcloud_snapshot/resource'
require_relative 'pangea/resources/hcloud_ssh_key/resource'
require_relative 'pangea/resources/hcloud_uploaded_certificate/resource'
require_relative 'pangea/resources/hcloud_volume/resource'
require_relative 'pangea/resources/hcloud_volume_attachment/resource'
require_relative 'pangea/resources/hcloud_zone/resource'
require_relative 'pangea/resources/hcloud_zone_rrset/resource'
