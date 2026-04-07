# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Dry::Struct attribute validation for resource types' do
  let(:hcloud_types) { Pangea::Resources::Hcloud::Types }

  describe 'ServerAttributes' do
    it 'accepts valid required-only attributes' do
      attrs = hcloud_types::ServerAttributes.new(name: 'web', server_type: 'cx21')
      expect(attrs.name).to eq('web')
      expect(attrs.server_type).to eq('cx21')
    end

    it 'defaults optional attributes to nil' do
      attrs = hcloud_types::ServerAttributes.new(name: 'web', server_type: 'cx21')
      expect(attrs.image).to be_nil
      expect(attrs.backups).to be_nil
      expect(attrs.ssh_keys).to be_nil
    end

    it 'rejects wrong type for boolean fields' do
      expect {
        hcloud_types::ServerAttributes.new(name: 'web', server_type: 'cx21', backups: 'yes')
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects wrong type for required string field' do
      expect {
        hcloud_types::ServerAttributes.new(name: 123, server_type: 'cx21')
      }.to raise_error(Dry::Struct::Error)
    end
  end

  describe 'NetworkAttributes' do
    it 'requires both ip_range and name' do
      expect {
        hcloud_types::NetworkAttributes.new(ip_range: '10.0.0.0/8')
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts all valid optional booleans' do
      attrs = hcloud_types::NetworkAttributes.new(
        ip_range: '10.0.0.0/8',
        name: 'net',
        delete_protection: true,
        expose_routes_to_vswitch: false
      )
      expect(attrs.delete_protection).to eq(true)
      expect(attrs.expose_routes_to_vswitch).to eq(false)
    end
  end

  describe 'FirewallAttributes' do
    it 'accepts rule as array of hashes' do
      attrs = hcloud_types::FirewallAttributes.new(
        name: 'fw',
        rule: [{ 'direction' => 'in', 'protocol' => 'tcp', 'port' => '80' }]
      )
      expect(attrs.rule.length).to eq(1)
    end

    it 'accepts apply_to as array of hashes' do
      attrs = hcloud_types::FirewallAttributes.new(
        name: 'fw',
        apply_to: [{ 'server' => 123 }]
      )
      expect(attrs.apply_to.length).to eq(1)
    end
  end

  describe 'FloatingIpAttributes' do
    it 'requires type field' do
      expect {
        hcloud_types::FloatingIpAttributes.new({})
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts optional description and labels' do
      attrs = hcloud_types::FloatingIpAttributes.new(
        type: 'ipv4',
        description: 'web IP',
        labels: { 'env' => 'prod' }
      )
      expect(attrs.description).to eq('web IP')
      expect(attrs.labels).to eq({ 'env' => 'prod' })
    end
  end

  describe 'CertificateAttributes' do
    it 'requires certificate, name, and private_key' do
      expect {
        hcloud_types::CertificateAttributes.new(name: 'cert', certificate: 'data')
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts all three required fields' do
      attrs = hcloud_types::CertificateAttributes.new(
        certificate: 'cert-data',
        name: 'my-cert',
        private_key: 'key-data'
      )
      expect(attrs.certificate).to eq('cert-data')
      expect(attrs.name).to eq('my-cert')
      expect(attrs.private_key).to eq('key-data')
    end
  end

  describe 'PrimaryIpAttributes' do
    it 'requires auto_delete as a boolean (not optional)' do
      expect {
        hcloud_types::PrimaryIpAttributes.new(assignee_type: 'server', type: 'ipv4')
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts auto_delete=false' do
      attrs = hcloud_types::PrimaryIpAttributes.new(
        assignee_type: 'server',
        auto_delete: false,
        type: 'ipv4'
      )
      expect(attrs.auto_delete).to eq(false)
    end
  end

  describe 'VolumeAttributes' do
    it 'requires size as Float' do
      expect {
        hcloud_types::VolumeAttributes.new(name: 'vol')
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts valid volume attributes' do
      attrs = hcloud_types::VolumeAttributes.new(name: 'data', size: 100.0, format: 'ext4')
      expect(attrs.size).to eq(100.0)
      expect(attrs.format).to eq('ext4')
    end
  end

  describe 'RdnsAttributes' do
    it 'requires dns_ptr and ip_address' do
      expect {
        hcloud_types::RdnsAttributes.new(dns_ptr: 'server1.example.com')
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts all optional ID fields as Float' do
      attrs = hcloud_types::RdnsAttributes.new(
        dns_ptr: 'server.example.com',
        ip_address: '1.2.3.4',
        server_id: 42.0,
        floating_ip_id: nil,
        primary_ip_id: nil
      )
      expect(attrs.server_id).to eq(42.0)
      expect(attrs.floating_ip_id).to be_nil
    end
  end

  describe 'ZoneRrsetAttributes' do
    it 'requires records as array of hashes' do
      attrs = hcloud_types::ZoneRrsetAttributes.new(
        name: '@',
        records: [{ 'value' => '1.2.3.4' }],
        type: 'A',
        zone: 'example.com'
      )
      expect(attrs.records).to eq([{ 'value' => '1.2.3.4' }])
    end

    it 'accepts optional ttl as Float' do
      attrs = hcloud_types::ZoneRrsetAttributes.new(
        name: '@',
        records: [{ 'value' => '1.2.3.4' }],
        type: 'A',
        zone: 'example.com',
        ttl: 300.0
      )
      expect(attrs.ttl).to eq(300.0)
    end
  end

  describe 'StorageBoxAttributes' do
    it 'requires all four required fields' do
      expect {
        hcloud_types::StorageBoxAttributes.new(
          location: 'fsn1',
          name: 'box',
          password: 'secret'
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts snapshot_plan as optional hash' do
      attrs = hcloud_types::StorageBoxAttributes.new(
        location: 'fsn1',
        name: 'box',
        password: 'secret',
        storage_box_type: 'bx10',
        snapshot_plan: { 'hour' => 3, 'day_of_week' => 'monday' }
      )
      expect(attrs.snapshot_plan).to be_a(Hash)
    end
  end

  describe 'NetworkSubnetAttributes' do
    it 'requires all four required fields' do
      expect {
        hcloud_types::NetworkSubnetAttributes.new(
          ip_range: '10.0.1.0/24',
          network_id: 1.0,
          network_zone: 'eu-central'
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts vswitch_id as optional Float' do
      attrs = hcloud_types::NetworkSubnetAttributes.new(
        ip_range: '10.0.1.0/24',
        network_id: 1.0,
        network_zone: 'eu-central',
        type: 'vswitch',
        vswitch_id: 42.0
      )
      expect(attrs.vswitch_id).to eq(42.0)
    end
  end

  describe 'LoadBalancerTargetAttributes' do
    it 'requires load_balancer_id and type' do
      expect {
        hcloud_types::LoadBalancerTargetAttributes.new(type: 'server')
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts optional target identifiers' do
      attrs = hcloud_types::LoadBalancerTargetAttributes.new(
        load_balancer_id: 1.0,
        type: 'server',
        server_id: 42.0,
        label_selector: nil
      )
      expect(attrs.server_id).to eq(42.0)
      expect(attrs.label_selector).to be_nil
    end
  end
end
