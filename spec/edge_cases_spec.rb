# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Resource edge cases' do
  include Pangea::Testing::SynthesisTestHelpers

  describe 'empty optional collections' do
    it 'includes empty labels hash in synthesis (map_present treats {} as present)' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudNetwork)
      synth.hcloud_network('test', { ip_range: '10.0.0.0/8', name: 'net', labels: {} })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_network', 'test')
      expect(config).to have_key('labels')
      expect(config['labels']).to eq({})
    end

    it 'includes non-empty labels hash in synthesis' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudNetwork)
      synth.hcloud_network('test', { ip_range: '10.0.0.0/8', name: 'net', labels: { 'env' => 'test' } })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_network', 'test')
      expect(config).to have_key('labels')
      expect(config['labels']).to eq({ 'env' => 'test' })
    end

    it 'includes empty arrays for optional list attributes via map_present' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudFirewall)
      synth.hcloud_firewall('test', { name: 'fw', rule: [] })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_firewall', 'test')
      expect(config).to have_key('rule')
      expect(config['rule']).to eq([])
    end

    it 'omits nil labels from synthesis' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudNetwork)
      synth.hcloud_network('test', { ip_range: '10.0.0.0/8', name: 'net', labels: nil })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_network', 'test')
      expect(config).not_to have_key('labels')
    end
  end

  describe 'nil optional values' do
    it 'omits nil optional string attributes' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)
      synth.hcloud_server('test', { name: 'srv', server_type: 'cx21', image: nil })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_server', 'test')
      expect(config).not_to have_key('image')
    end

    it 'omits nil optional boolean attributes' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)
      synth.hcloud_server('test', { name: 'srv', server_type: 'cx21', backups: nil })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_server', 'test')
      expect(config).not_to have_key('backups')
    end

    it 'omits nil optional float attributes' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)
      synth.hcloud_server('test', { name: 'srv', server_type: 'cx21', placement_group_id: nil })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_server', 'test')
      expect(config).not_to have_key('placement_group_id')
    end
  end

  describe 'attribute value preservation' do
    it 'preserves exact string values in required attributes' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)
      synth.hcloud_server('test', { name: 'my-web-server', server_type: 'cpx31' })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_server', 'test')
      expect(config['name']).to eq('my-web-server')
      expect(config['server_type']).to eq('cpx31')
    end

    it 'preserves exact float values' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudVolume)
      synth.hcloud_volume('test', { name: 'vol', size: 50.0 })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_volume', 'test')
      expect(config['size']).to eq(50.0)
    end

    it 'preserves exact label key-value pairs' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)
      labels = { 'env' => 'production', 'team' => 'platform', 'cost-center' => 'eng-123' }
      synth.hcloud_server('test', { name: 'srv', server_type: 'cx21', labels: labels })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_server', 'test')
      expect(config['labels']).to eq(labels)
    end

    it 'preserves array of strings in ssh_keys' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)
      keys = ['key1', 'key2', 'key3']
      synth.hcloud_server('test', { name: 'srv', server_type: 'cx21', ssh_keys: keys })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_server', 'test')
      expect(config['ssh_keys']).to eq(keys)
    end

    it 'preserves nested hash structures in network blocks' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)
      network = [{ 'network_id' => 123, 'ip' => '10.0.0.5' }]
      synth.hcloud_server('test', { name: 'srv', server_type: 'cx21', network: network })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_server', 'test')
      expect(config['network']).to eq(network)
    end
  end

  describe 'resource names with special characters' do
    it 'accepts hyphenated resource names' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)
      ref = synth.hcloud_server('web-server-01', { name: 'web', server_type: 'cx21' })
      expect(ref.id).to eq('${hcloud_server.web-server-01.id}')
    end

    it 'accepts underscored resource names' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)
      ref = synth.hcloud_server('web_server_01', { name: 'web', server_type: 'cx21' })
      expect(ref.id).to eq('${hcloud_server.web_server_01.id}')
    end
  end

  describe 'ResourceReference output access' do
    it 'returns terraform interpolation for any attribute via method_missing' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)
      ref = synth.hcloud_server('web', { name: 'web', server_type: 'cx21' })
      expect(ref.ipv4_address).to eq('${hcloud_server.web.ipv4_address}')
      expect(ref.ipv6_address).to eq('${hcloud_server.web.ipv6_address}')
      expect(ref.status).to eq('${hcloud_server.web.status}')
    end

    it 'returns correct resource_type as symbol' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudNetwork)
      ref = synth.hcloud_network('main', { ip_range: '10.0.0.0/8', name: 'main' })
      expect(ref.resource_type).to eq(:hcloud_network)
    end

    it 'stores resource_attributes on the reference' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudSshKey)
      ref = synth.hcloud_ssh_key('key', { name: 'deploy', public_key: 'ssh-rsa AAAA' })
      expect(ref.resource_attributes).to include(name: 'deploy', public_key: 'ssh-rsa AAAA')
    end
  end

  describe 'boolean false explicit vs nil omission' do
    it 'includes false boolean (explicit) in synthesis' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)
      synth.hcloud_server('test', { name: 'srv', server_type: 'cx21', backups: false })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_server', 'test')
      expect(config).to have_key('backups')
      expect(config['backups']).to eq(false)
    end

    it 'excludes nil boolean (omitted) from synthesis' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)
      synth.hcloud_server('test', { name: 'srv', server_type: 'cx21' })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_server', 'test')
      expect(config).not_to have_key('backups')
    end

    it 'distinguishes false from nil for delete_protection' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudNetwork)

      synth.hcloud_network('with_false', { ip_range: '10.0.0.0/8', name: 'net', delete_protection: false })
      synth.hcloud_network('without', { ip_range: '10.0.0.0/8', name: 'net2' })

      result = normalize_synthesis(synth.synthesis)
      false_config = result.dig('resource', 'hcloud_network', 'with_false')
      nil_config = result.dig('resource', 'hcloud_network', 'without')

      expect(false_config).to have_key('delete_protection')
      expect(false_config['delete_protection']).to eq(false)
      expect(nil_config).not_to have_key('delete_protection')
    end
  end

  describe 'multiple resources of same type' do
    it 'maintains independent configurations for three instances' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)

      synth.hcloud_server('web', { name: 'web', server_type: 'cx21' })
      synth.hcloud_server('api', { name: 'api', server_type: 'cpx31', backups: true })
      synth.hcloud_server('db', { name: 'db', server_type: 'ccx33', delete_protection: true })

      result = normalize_synthesis(synth.synthesis)
      servers = result.dig('resource', 'hcloud_server')

      expect(servers.keys).to contain_exactly('web', 'api', 'db')
      expect(servers['web']['server_type']).to eq('cx21')
      expect(servers['api']['server_type']).to eq('cpx31')
      expect(servers['api']).to have_key('backups')
      expect(servers['db']['server_type']).to eq('ccx33')
      expect(servers['db']).to have_key('delete_protection')
      expect(servers['web']).not_to have_key('backups')
    end
  end
end
