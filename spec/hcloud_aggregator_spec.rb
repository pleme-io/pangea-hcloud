# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pangea::Resources::Hcloud do
  include Pangea::Testing::SynthesisTestHelpers

  describe 'aggregator module' do
    it 'responds to all 29 resource methods' do
      synth = create_synthesizer
      synth.extend(described_class)

      expected_methods = %i[
        hcloud_certificate hcloud_firewall hcloud_firewall_attachment
        hcloud_floating_ip hcloud_floating_ip_assignment
        hcloud_load_balancer hcloud_load_balancer_network
        hcloud_load_balancer_service hcloud_load_balancer_target
        hcloud_managed_certificate hcloud_network hcloud_network_route
        hcloud_network_subnet hcloud_placement_group hcloud_primary_ip
        hcloud_rdns hcloud_server hcloud_server_network hcloud_snapshot
        hcloud_ssh_key hcloud_storage_box hcloud_storage_box_snapshot
        hcloud_storage_box_subaccount hcloud_uploaded_certificate
        hcloud_volume hcloud_volume_attachment hcloud_zone
        hcloud_zone_record hcloud_zone_rrset
      ]

      expected_methods.each do |method|
        expect(synth).to respond_to(method), "Expected Hcloud module to provide ##{method}"
      end
    end

    it 'can synthesize multiple different resource types in a single synthesizer' do
      synth = create_synthesizer
      synth.extend(described_class)

      synth.hcloud_network('main', { ip_range: '10.0.0.0/8', name: 'main-net' })
      synth.hcloud_server('web', { name: 'web-01', server_type: 'cx21' })
      synth.hcloud_ssh_key('deploy', { name: 'deploy-key', public_key: 'ssh-rsa AAAA' })

      result = normalize_synthesis(synth.synthesis)
      expect(result['resource'].keys).to include('hcloud_network', 'hcloud_server', 'hcloud_ssh_key')
    end

    it 'keeps resources of different types isolated' do
      synth = create_synthesizer
      synth.extend(described_class)

      synth.hcloud_network('main', { ip_range: '10.0.0.0/8', name: 'main-net' })
      synth.hcloud_server('web', { name: 'web-01', server_type: 'cx21' })

      result = normalize_synthesis(synth.synthesis)
      expect(result.dig('resource', 'hcloud_network').keys).to eq(['main'])
      expect(result.dig('resource', 'hcloud_server').keys).to eq(['web'])
    end
  end

  describe 'cross-resource references' do
    it 'allows using one resource output as another resource attribute' do
      synth = create_synthesizer
      synth.extend(described_class)

      net_ref = synth.hcloud_network('main', { ip_range: '10.0.0.0/8', name: 'main-net' })

      synth.hcloud_network_subnet('web-subnet', {
        ip_range: '10.0.1.0/24',
        network_id: 123.0,
        network_zone: 'eu-central',
        type: 'cloud'
      })

      result = normalize_synthesis(synth.synthesis)
      expect(result['resource']).to have_key('hcloud_network')
      expect(result['resource']).to have_key('hcloud_network_subnet')
      expect(net_ref.id).to eq('${hcloud_network.main.id}')
    end

    it 'links server to network via server_network' do
      synth = create_synthesizer
      synth.extend(described_class)

      server_ref = synth.hcloud_server('web', { name: 'web', server_type: 'cx21' })
      synth.hcloud_server_network('web-net', { server_id: 1.0, subnet_id: 'test-subnet' })

      result = normalize_synthesis(synth.synthesis)
      expect(result['resource']).to have_key('hcloud_server')
      expect(result['resource']).to have_key('hcloud_server_network')
      expect(server_ref.id).to eq('${hcloud_server.web.id}')
    end

    it 'links firewall to firewall_attachment' do
      synth = create_synthesizer
      synth.extend(described_class)

      fw_ref = synth.hcloud_firewall('web-fw', { name: 'web-firewall' })
      synth.hcloud_firewall_attachment('web-fw-attach', {
        firewall_id: 1.0,
        server_ids: [1.0, 2.0]
      })

      result = normalize_synthesis(synth.synthesis)
      expect(result['resource']).to have_key('hcloud_firewall')
      expect(result['resource']).to have_key('hcloud_firewall_attachment')
      expect(fw_ref.id).to eq('${hcloud_firewall.web-fw.id}')
    end
  end
end
