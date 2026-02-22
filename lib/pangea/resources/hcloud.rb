# frozen_string_literal: true

require 'pangea/resources/types'
require 'pangea/resources/base'

# Require all hcloud resources
require_relative 'hcloud_certificate/resource'
require_relative 'hcloud_firewall/resource'
require_relative 'hcloud_firewall_attachment/resource'
require_relative 'hcloud_floating_ip/resource'
require_relative 'hcloud_floating_ip_assignment/resource'
require_relative 'hcloud_load_balancer/resource'
require_relative 'hcloud_load_balancer_network/resource'
require_relative 'hcloud_load_balancer_service/resource'
require_relative 'hcloud_load_balancer_target/resource'
require_relative 'hcloud_managed_certificate/resource'
require_relative 'hcloud_network/resource'
require_relative 'hcloud_network_route/resource'
require_relative 'hcloud_network_subnet/resource'
require_relative 'hcloud_placement_group/resource'
require_relative 'hcloud_primary_ip/resource'
require_relative 'hcloud_rdns/resource'
require_relative 'hcloud_server/resource'
require_relative 'hcloud_server_network/resource'
require_relative 'hcloud_snapshot/resource'
require_relative 'hcloud_ssh_key/resource'
require_relative 'hcloud_uploaded_certificate/resource'
require_relative 'hcloud_volume/resource'
require_relative 'hcloud_volume_attachment/resource'
require_relative 'hcloud_zone/resource'
require_relative 'hcloud_zone_rrset/resource'

module Pangea
  module Resources
    module Hcloud
      include Base
      include HcloudCertificate
      include HcloudFirewall
      include HcloudFirewallAttachment
      include HcloudFloatingIp
      include HcloudFloatingIpAssignment
      include HcloudLoadBalancer
      include HcloudLoadBalancerNetwork
      include HcloudLoadBalancerService
      include HcloudLoadBalancerTarget
      include HcloudManagedCertificate
      include HcloudNetwork
      include HcloudNetworkRoute
      include HcloudNetworkSubnet
      include HcloudPlacementGroup
      include HcloudPrimaryIp
      include HcloudRdns
      include HcloudServer
      include HcloudServerNetwork
      include HcloudSnapshot
      include HcloudSshKey
      include HcloudUploadedCertificate
      include HcloudVolume
      include HcloudVolumeAttachment
      include HcloudZone
      include HcloudZoneRrset
    end
  end
end
