# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ResourceBuilder error paths and edge cases' do
  include Pangea::Testing::SynthesisTestHelpers

  describe 'unknown attribute rejection' do
    it 'raises ArgumentError for typo in attribute name on hcloud_server' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)
      expect {
        synth.hcloud_server('test', { name: 'test', server_type: 'cx21', nme: 'typo' })
      }.to raise_error(ArgumentError, /unknown attributes.*nme/)
    end

    it 'raises ArgumentError for unknown attribute on hcloud_network' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudNetwork)
      expect {
        synth.hcloud_network('test', { ip_range: '10.0.0.0/8', name: 'net', nonexistent: 'val' })
      }.to raise_error(ArgumentError, /unknown attributes.*nonexistent/)
    end

    it 'includes valid attribute list in error message' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudSshKey)
      expect {
        synth.hcloud_ssh_key('test', { name: 'key', public_key: 'ssh-rsa ...', typo_field: 'x' })
      }.to raise_error(ArgumentError, /Valid attributes:/)
    end
  end

  describe 'missing required attributes' do
    it 'raises error when required attributes are missing for hcloud_server' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)
      expect {
        synth.hcloud_server('test', {})
      }.to raise_error(Dry::Struct::Error)
    end

    it 'raises error when a required string is missing for hcloud_network' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudNetwork)
      expect {
        synth.hcloud_network('test', { ip_range: '10.0.0.0/8' })
      }.to raise_error(Dry::Struct::Error)
    end

    it 'raises error when required float is missing for hcloud_floating_ip_assignment' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudFloatingIpAssignment)
      expect {
        synth.hcloud_floating_ip_assignment('test', { floating_ip_id: 1.0 })
      }.to raise_error(Dry::Struct::Error)
    end
  end

  describe 'Dry::Struct type coercion' do
    it 'coerces string keys to symbols via transform_keys' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudSshKey)
      ref = synth.hcloud_ssh_key('test', { 'name' => 'my-key', 'public_key' => 'ssh-rsa AAAA...' })
      expect(ref).to be_a(Pangea::Resources::ResourceReference)
      expect(ref.resource_type).to eq(:hcloud_ssh_key)
    end

    it 'handles numeric IDs as Float for hcloud_network_route' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudNetworkRoute)
      ref = synth.hcloud_network_route('test', {
        destination: '10.100.0.0/16',
        gateway: '10.0.1.1',
        network_id: 42.0
      })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_network_route', 'test')
      expect(config['network_id']).to eq(42.0)
    end
  end

  describe 'Terraform meta-arguments' do
    it 'passes lifecycle meta-argument through to synthesis' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudServer)
      synth.hcloud_server('test', {
        name: 'test',
        server_type: 'cx21',
        lifecycle: { create_before_destroy: true }
      })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_server', 'test')
      expect(config).to have_key('lifecycle')
    end

    it 'passes depends_on meta-argument through to synthesis' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudNetwork)
      synth.hcloud_network('test', {
        ip_range: '10.0.0.0/8',
        name: 'test-net',
        depends_on: ['hcloud_server.web']
      })
      result = normalize_synthesis(synth.synthesis)
      config = validate_resource_structure(result, 'hcloud_network', 'test')
      expect(config).to have_key('depends_on')
    end

    it 'does not treat meta-arguments as resource attributes' do
      synth = create_synthesizer
      synth.extend(Pangea::Resources::HcloudSshKey)
      ref = synth.hcloud_ssh_key('test', {
        name: 'my-key',
        public_key: 'ssh-rsa AAAA',
        lifecycle: { prevent_destroy: true }
      })
      expect(ref).to be_a(Pangea::Resources::ResourceReference)
    end
  end
end
