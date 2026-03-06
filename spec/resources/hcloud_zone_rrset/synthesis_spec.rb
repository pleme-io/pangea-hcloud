# frozen_string_literal: true
# Copyright 2025 The Pangea Authors

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/hcloud_zone_rrset/resource'
require 'pangea/resources/hcloud_zone_rrset/types'

RSpec.describe 'hcloud_zone_rrset synthesis' do
  include Pangea::Resources::Hetzner

  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes A record set' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_zone_rrset(:web_a_record, {
          zone_id: "${hcloud_zone.primary_zone.id}",
          name: "www",
          type: "A",
          values: ["192.0.2.1", "192.0.2.2"],
          ttl: 3600
        })
      end

      result = synthesizer.synthesis
      rrset = result[:resource][:hcloud_zone_rrset][:web_a_record]

      expect(rrset[:zone_id]).to eq("${hcloud_zone.primary_zone.id}")
      expect(rrset[:name]).to eq("www")
      expect(rrset[:type]).to eq("A")
      expect(rrset[:values]).to eq(["192.0.2.1", "192.0.2.2"])
      expect(rrset[:ttl]).to eq(3600)
    end

    it 'synthesizes AAAA record set' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_zone_rrset(:ipv6_record, {
          zone_id: "zone-123",
          name: "www",
          type: "AAAA",
          values: ["2001:db8::1"]
        })
      end

      result = synthesizer.synthesis
      rrset = result[:resource][:hcloud_zone_rrset][:ipv6_record]

      expect(rrset[:type]).to eq("AAAA")
    end

    it 'synthesizes CNAME record set' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_zone_rrset(:cname, {
          zone_id: "zone-123",
          name: "app",
          type: "CNAME",
          values: ["www.example.com"]
        })
      end

      result = synthesizer.synthesis
      rrset = result[:resource][:hcloud_zone_rrset][:cname]

      expect(rrset[:type]).to eq("CNAME")
      expect(rrset[:values]).to eq(["www.example.com"])
    end

    it 'synthesizes MX record set' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_zone_rrset(:mx, {
          zone_id: "zone-123",
          name: "@",
          type: "MX",
          values: ["10 mail.example.com", "20 backup-mail.example.com"],
          ttl: 3600
        })
      end

      result = synthesizer.synthesis
      rrset = result[:resource][:hcloud_zone_rrset][:mx]

      expect(rrset[:type]).to eq("MX")
      expect(rrset[:values].length).to eq(2)
    end

    it 'synthesizes TXT record set' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_zone_rrset(:spf, {
          zone_id: "zone-123",
          name: "@",
          type: "TXT",
          values: ["v=spf1 include:_spf.google.com ~all"]
        })
      end

      result = synthesizer.synthesis
      rrset = result[:resource][:hcloud_zone_rrset][:spf]

      expect(rrset[:type]).to eq("TXT")
    end

    it 'synthesizes SRV record set' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_zone_rrset(:srv, {
          zone_id: "zone-123",
          name: "_sip._tcp",
          type: "SRV",
          values: ["10 5 5060 sip.example.com"]
        })
      end

      result = synthesizer.synthesis
      rrset = result[:resource][:hcloud_zone_rrset][:srv]

      expect(rrset[:type]).to eq("SRV")
    end

    it 'synthesizes record set without TTL' do
      synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_zone_rrset(:no_ttl, {
          zone_id: "zone-123",
          name: "test",
          type: "A",
          values: ["1.2.3.4"]
        })
      end

      result = synthesizer.synthesis
      rrset = result[:resource][:hcloud_zone_rrset][:no_ttl]

      expect(rrset[:name]).to eq("test")
      expect(rrset).not_to have_key(:ttl)
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::Hetzner
        hcloud_zone_rrset(:test, {
          zone_id: "zone-123",
          name: "test",
          type: "A",
          values: ["1.2.3.4"]
        })
      end

      expect(ref.id).to eq("${hcloud_zone_rrset.test.id}")
      expect(ref.outputs[:zone_id]).to eq("${hcloud_zone_rrset.test.zone_id}")
      expect(ref.outputs[:name]).to eq("${hcloud_zone_rrset.test.name}")
      expect(ref.outputs[:type]).to eq("${hcloud_zone_rrset.test.type}")
    end
  end

  describe 'type validation' do
    it 'rejects missing required zone_id' do
      expect {
        Pangea::Resources::Hetzner::Types::ZoneRrsetAttributes.new(
          name: "test", type: "A", values: ["1.2.3.4"]
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required name' do
      expect {
        Pangea::Resources::Hetzner::Types::ZoneRrsetAttributes.new(
          zone_id: "zone-123", type: "A", values: ["1.2.3.4"]
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required type' do
      expect {
        Pangea::Resources::Hetzner::Types::ZoneRrsetAttributes.new(
          zone_id: "zone-123", name: "test", values: ["1.2.3.4"]
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects missing required values' do
      expect {
        Pangea::Resources::Hetzner::Types::ZoneRrsetAttributes.new(
          zone_id: "zone-123", name: "test", type: "A"
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects invalid DNS record type' do
      expect {
        Pangea::Resources::Hetzner::Types::ZoneRrsetAttributes.new(
          zone_id: "zone-123", name: "test", type: "INVALID", values: ["1.2.3.4"]
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts all valid DNS record types' do
      %w[A AAAA NS MX CNAME RP TXT SOA HINFO SRV DANE TLSA DS CAA].each do |rt|
        attrs = Pangea::Resources::Hetzner::Types::ZoneRrsetAttributes.new(
          zone_id: "zone-123", name: "test", type: rt, values: ["value"]
        )
        expect(attrs.type).to eq(rt)
      end
    end

    it 'rejects TTL below minimum (60)' do
      expect {
        Pangea::Resources::Hetzner::Types::ZoneRrsetAttributes.new(
          zone_id: "zone-123", name: "test", type: "A", values: ["1.2.3.4"], ttl: 30
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'rejects TTL above maximum (86400)' do
      expect {
        Pangea::Resources::Hetzner::Types::ZoneRrsetAttributes.new(
          zone_id: "zone-123", name: "test", type: "A", values: ["1.2.3.4"], ttl: 100000
        )
      }.to raise_error(Dry::Struct::Error)
    end

    it 'defaults TTL to nil' do
      attrs = Pangea::Resources::Hetzner::Types::ZoneRrsetAttributes.new(
        zone_id: "zone-123", name: "test", type: "A", values: ["1.2.3.4"]
      )
      expect(attrs.ttl).to be_nil
    end
  end
end
