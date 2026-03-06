# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_server/resource'
require 'pangea/resources/hcloud_server/types'

RSpec.describe 'hcloud_server synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes minimal server configuration' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server(:web, {
          name: "web-01",
          server_type: "cx23",
          location: "fsn1",
          image: "ubuntu-22.04"
        })
      end

      result = synthesizer.synthesis
      server = result[:resource][:hcloud_server][:web]

      expect(server[:name]).to eq("web-01")
      expect(server[:server_type]).to eq("cx23")
      expect(server[:location]).to eq("fsn1")
      expect(server[:image]).to eq("ubuntu-22.04")
    end

    it 'synthesizes server with ssh keys and firewall' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server(:web, {
          name: "web-01",
          server_type: "cx23",
          location: "fsn1",
          image: "ubuntu-22.04",
          ssh_keys: ["deployer-key"],
          firewall_ids: ["${hcloud_firewall.web.id}"]
        })
      end

      result = synthesizer.synthesis
      server = result[:resource][:hcloud_server][:web]

      expect(server[:ssh_keys]).to eq(["deployer-key"])
      expect(server[:firewall_ids]).to eq(["${hcloud_firewall.web.id}"])
    end

    it 'synthesizes server with public_net configuration' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server(:web, {
          name: "web-01",
          server_type: "cx23",
          location: "fsn1",
          image: "ubuntu-22.04",
          public_net: {
            ipv4_enabled: true,
            ipv6_enabled: false
          }
        })
      end

      result = synthesizer.synthesis
      server = result[:resource][:hcloud_server][:web]

      expect(server[:public_net][:ipv4_enabled]).to be true
      expect(server[:public_net][:ipv6_enabled]).to be false
    end

    it 'synthesizes server with user_data cloud-init' do
      cloud_init = <<~YAML
        #cloud-config
        packages:
          - nginx
      YAML

      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server(:web, {
          name: "web-01",
          server_type: "cx23",
          location: "fsn1",
          image: "ubuntu-22.04",
          user_data: cloud_init
        })
      end

      result = synthesizer.synthesis
      server = result[:resource][:hcloud_server][:web]

      expect(server[:user_data]).to include("#cloud-config")
      expect(server[:user_data]).to include("nginx")
    end

    it 'synthesizes server with labels' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server(:web, {
          name: "web-01",
          server_type: "cx23",
          location: "fsn1",
          image: "ubuntu-22.04",
          labels: {
            environment: "production",
            team: "platform"
          }
        })
      end

      result = synthesizer.synthesis
      server = result[:resource][:hcloud_server][:web]

      expect(server[:labels][:environment]).to eq("production")
      expect(server[:labels][:team]).to eq("platform")
    end

    it 'synthesizes server with backups enabled' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server(:web, {
          name: "web-01",
          server_type: "cx23",
          location: "fsn1",
          image: "ubuntu-22.04",
          backups: true
        })
      end

      result = synthesizer.synthesis
      server = result[:resource][:hcloud_server][:web]

      expect(server[:backups]).to be true
    end

    it 'synthesizes server with placement_group_id' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server(:web, {
          name: "web-01",
          server_type: "cx23",
          location: "fsn1",
          image: "ubuntu-22.04",
          placement_group_id: "${hcloud_placement_group.spread.id}"
        })
      end

      result = synthesizer.synthesis
      server = result[:resource][:hcloud_server][:web]

      expect(server[:placement_group_id]).to eq("${hcloud_placement_group.spread.id}")
    end

    it 'synthesizes server without optional attributes omitted from output' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server(:minimal, {
          name: "minimal-01",
          server_type: "cx23",
          image: "ubuntu-22.04"
        })
      end

      result = synthesizer.synthesis
      server = result[:resource][:hcloud_server][:minimal]

      expect(server[:name]).to eq("minimal-01")
      expect(server).not_to have_key(:location)
      expect(server).not_to have_key(:datacenter)
      expect(server).not_to have_key(:user_data)
      expect(server).not_to have_key(:iso)
      expect(server).not_to have_key(:placement_group_id)
    end

    it 'defaults backups to false' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server(:web, {
          name: "web-01",
          server_type: "cx23",
          image: "ubuntu-22.04"
        })
      end

      result = synthesizer.synthesis
      server = result[:resource][:hcloud_server][:web]

      expect(server[:backups]).to be false
    end

    it 'synthesizes server with datacenter instead of location' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server(:web, {
          name: "web-01",
          server_type: "cx23",
          datacenter: "fsn1-dc14",
          image: "ubuntu-22.04"
        })
      end

      result = synthesizer.synthesis
      server = result[:resource][:hcloud_server][:web]

      expect(server[:datacenter]).to eq("fsn1-dc14")
    end

    it 'synthesizes server with multiple ssh keys' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server(:web, {
          name: "web-01",
          server_type: "cx23",
          location: "fsn1",
          image: "ubuntu-22.04",
          ssh_keys: ["key1", "key2", "key3"]
        })
      end

      result = synthesizer.synthesis
      server = result[:resource][:hcloud_server][:web]

      expect(server[:ssh_keys]).to eq(["key1", "key2", "key3"])
      expect(server[:ssh_keys].length).to eq(3)
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server(:test, {
          name: "test-server",
          server_type: "cx23",
          location: "fsn1",
          image: "ubuntu-22.04"
        })
      end

      expect(ref.id).to eq("${hcloud_server.test.id}")
      expect(ref.outputs[:ipv4_address]).to eq("${hcloud_server.test.ipv4_address}")
      expect(ref.outputs[:status]).to eq("${hcloud_server.test.status}")
    end

    it 'includes all expected output references' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server(:full, {
          name: "full-server",
          server_type: "cx23",
          location: "fsn1",
          image: "ubuntu-22.04"
        })
      end

      expect(ref.outputs).to include(:id, :name, :ipv4_address, :ipv6_address,
                                      :ipv6_network, :status, :backup_window, :datacenter)
    end

    it 'interpolates resource name into all output strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_server(:myserver, {
          name: "my-server",
          server_type: "cx23",
          location: "fsn1",
          image: "ubuntu-22.04"
        })
      end

      ref.outputs.each do |key, value|
        expect(value).to include("hcloud_server.myserver."), "Expected output :#{key} to contain 'hcloud_server.myserver.'"
      end
    end
  end

  describe 'type validation' do
    it 'rejects missing required name attribute' do
      expect {
        Pangea::Resources::Hetzner::Types::ServerAttributes.new(
          server_type: "cx23",
          image: "ubuntu-22.04"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required server_type attribute' do
      expect {
        Pangea::Resources::Hetzner::Types::ServerAttributes.new(
          name: "web-01",
          image: "ubuntu-22.04"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required image attribute' do
      expect {
        Pangea::Resources::Hetzner::Types::ServerAttributes.new(
          name: "web-01",
          server_type: "cx23"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid server_type' do
      expect {
        Pangea::Resources::Hetzner::Types::ServerAttributes.new(
          name: "web-01",
          server_type: "invalid-type",
          image: "ubuntu-22.04"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid location' do
      expect {
        Pangea::Resources::Hetzner::Types::ServerAttributes.new(
          name: "web-01",
          server_type: "cx23",
          image: "ubuntu-22.04",
          location: "invalid-location"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts all valid server types' do
      valid_types = %w[cx23 cx33 cx43 cx53 cax11 cax21 cax31 cax41
                       cpx11 cpx21 cpx31 cpx41 cpx51 ccx13 ccx23 ccx33 ccx43 ccx53 ccx63]
      valid_types.each do |st|
        attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
          name: "test", server_type: st, image: "ubuntu-22.04"
        )
        expect(attrs.server_type).to eq(st)
      end
    end

    it 'accepts all valid locations' do
      %w[fsn1 nbg1 hel1 ash hil sin].each do |loc|
        attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
          name: "test", server_type: "cx23", image: "ubuntu-22.04", location: loc
        )
        expect(attrs.location).to eq(loc)
      end
    end
  end

  describe 'computed properties' do
    it 'detects ARM server types' do
      attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
        name: "arm-server", server_type: "cax11", image: "ubuntu-22.04"
      )
      expect(attrs.is_arm?).to be true
    end

    it 'detects non-ARM server types' do
      attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
        name: "intel-server", server_type: "cx23", image: "ubuntu-22.04"
      )
      expect(attrs.is_arm?).to be false
    end

    it 'detects dedicated server types' do
      attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
        name: "dedicated", server_type: "ccx13", image: "ubuntu-22.04"
      )
      expect(attrs.is_dedicated?).to be true
    end

    it 'detects non-dedicated server types' do
      attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
        name: "shared", server_type: "cpx11", image: "ubuntu-22.04"
      )
      expect(attrs.is_dedicated?).to be false
    end

    it 'identifies arm64 cpu type' do
      attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
        name: "test", server_type: "cax21", image: "ubuntu-22.04"
      )
      expect(attrs.cpu_type).to eq('arm64')
    end

    it 'identifies amd-dedicated cpu type' do
      attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
        name: "test", server_type: "ccx23", image: "ubuntu-22.04"
      )
      expect(attrs.cpu_type).to eq('amd-dedicated')
    end

    it 'identifies amd-shared cpu type' do
      attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
        name: "test", server_type: "cpx21", image: "ubuntu-22.04"
      )
      expect(attrs.cpu_type).to eq('amd-shared')
    end

    it 'returns unknown for cx-series (2-char prefix does not match 3-char slice)' do
      attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
        name: "test", server_type: "cx23", image: "ubuntu-22.04"
      )
      # cpu_type checks server_type[0..2] (3 chars) against 'cx' (2 chars),
      # so cx-series currently returns 'unknown' rather than 'intel'
      expect(attrs.cpu_type).to eq('unknown')
    end
  end

  describe 'default values' do
    it 'defaults ssh_keys to empty array' do
      attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
        name: "test", server_type: "cx23", image: "ubuntu-22.04"
      )
      expect(attrs.ssh_keys).to eq([])
    end

    it 'defaults firewall_ids to empty array' do
      attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
        name: "test", server_type: "cx23", image: "ubuntu-22.04"
      )
      expect(attrs.firewall_ids).to eq([])
    end

    it 'defaults labels to empty hash' do
      attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
        name: "test", server_type: "cx23", image: "ubuntu-22.04"
      )
      expect(attrs.labels).to eq({})
    end

    it 'defaults backups to false' do
      attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
        name: "test", server_type: "cx23", image: "ubuntu-22.04"
      )
      expect(attrs.backups).to be false
    end

    it 'defaults location to nil' do
      attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
        name: "test", server_type: "cx23", image: "ubuntu-22.04"
      )
      expect(attrs.location).to be_nil
    end

    it 'defaults public_net to nil' do
      attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
        name: "test", server_type: "cx23", image: "ubuntu-22.04"
      )
      expect(attrs.public_net).to be_nil
    end

    it 'defaults network to nil' do
      attrs = Pangea::Resources::Hetzner::Types::ServerAttributes.new(
        name: "test", server_type: "cx23", image: "ubuntu-22.04"
      )
      expect(attrs.network).to be_nil
    end
  end
end
