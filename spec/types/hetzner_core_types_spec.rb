# frozen_string_literal: true

require 'spec_helper'
require 'pangea/resources/types/hetzner/core'

RSpec.describe 'Pangea::Resources::Types Hetzner core types' do
  let(:types) { Pangea::Resources::Types }

  describe 'HetznerLocation' do
    it 'accepts valid locations' do
      %w[fsn1 nbg1 hel1 ash hil sin].each do |loc|
        expect(types::HetznerLocation[loc]).to eq(loc)
      end
    end

    it 'rejects invalid locations' do
      expect { types::HetznerLocation['invalid-dc'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerServerType' do
    it 'accepts all CX series types' do
      %w[cx23 cx33 cx43 cx53].each do |st|
        expect(types::HetznerServerType[st]).to eq(st)
      end
    end

    it 'accepts all CAX series types' do
      %w[cax11 cax21 cax31 cax41].each do |st|
        expect(types::HetznerServerType[st]).to eq(st)
      end
    end

    it 'accepts all CPX series types' do
      %w[cpx11 cpx21 cpx31 cpx41 cpx51].each do |st|
        expect(types::HetznerServerType[st]).to eq(st)
      end
    end

    it 'accepts all CCX series types' do
      %w[ccx13 ccx23 ccx33 ccx43 ccx53 ccx63].each do |st|
        expect(types::HetznerServerType[st]).to eq(st)
      end
    end

    it 'rejects unknown server types' do
      expect { types::HetznerServerType['m5.xlarge'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerNetworkZone' do
    it 'accepts valid zones' do
      %w[eu-central us-east us-west ap-southeast].each do |zone|
        expect(types::HetznerNetworkZone[zone]).to eq(zone)
      end
    end

    it 'rejects invalid zones' do
      expect { types::HetznerNetworkZone['eu-west-1'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerFirewallDirection' do
    it 'accepts in and out' do
      expect(types::HetznerFirewallDirection['in']).to eq('in')
      expect(types::HetznerFirewallDirection['out']).to eq('out')
    end

    it 'rejects invalid directions' do
      expect { types::HetznerFirewallDirection['both'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerFirewallProtocol' do
    it 'accepts all valid protocols' do
      %w[tcp udp icmp esp gre].each do |proto|
        expect(types::HetznerFirewallProtocol[proto]).to eq(proto)
      end
    end

    it 'rejects invalid protocols' do
      expect { types::HetznerFirewallProtocol['sctp'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerLoadBalancerType' do
    it 'accepts valid types' do
      %w[lb11 lb21 lb31].each do |t|
        expect(types::HetznerLoadBalancerType[t]).to eq(t)
      end
    end

    it 'rejects unknown types' do
      expect { types::HetznerLoadBalancerType['lb99'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerLoadBalancerAlgorithm' do
    it 'accepts round_robin' do
      expect(types::HetznerLoadBalancerAlgorithm['round_robin']).to eq('round_robin')
    end

    it 'accepts least_connections' do
      expect(types::HetznerLoadBalancerAlgorithm['least_connections']).to eq('least_connections')
    end

    it 'rejects invalid algorithms' do
      expect { types::HetznerLoadBalancerAlgorithm['random'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerCertificateType' do
    it 'accepts uploaded and managed' do
      expect(types::HetznerCertificateType['uploaded']).to eq('uploaded')
      expect(types::HetznerCertificateType['managed']).to eq('managed')
    end

    it 'rejects invalid types' do
      expect { types::HetznerCertificateType['self-signed'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerVolumeFormat' do
    it 'accepts xfs and ext4' do
      expect(types::HetznerVolumeFormat['xfs']).to eq('xfs')
      expect(types::HetznerVolumeFormat['ext4']).to eq('ext4')
    end

    it 'rejects invalid formats' do
      expect { types::HetznerVolumeFormat['ntfs'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerServerId' do
    it 'accepts positive integers' do
      expect(types::HetznerServerId[1]).to eq(1)
      expect(types::HetznerServerId[999_999]).to eq(999_999)
    end

    it 'rejects zero' do
      expect { types::HetznerServerId[0] }.to raise_error(Dry::Types::ConstraintError)
    end

    it 'rejects negative integers' do
      expect { types::HetznerServerId[-1] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerIpv4' do
    it 'accepts valid IPv4 addresses' do
      expect(types::HetznerIpv4['192.168.1.1']).to eq('192.168.1.1')
      expect(types::HetznerIpv4['10.0.0.0']).to eq('10.0.0.0')
      expect(types::HetznerIpv4['255.255.255.255']).to eq('255.255.255.255')
    end

    it 'rejects invalid IPv4 strings' do
      expect { types::HetznerIpv4['not-an-ip'] }.to raise_error(Dry::Types::ConstraintError)
      expect { types::HetznerIpv4[''] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerIpv6' do
    it 'accepts valid IPv6 addresses' do
      expect(types::HetznerIpv6['::1']).to eq('::1')
      expect(types::HetznerIpv6['2001:db8::1']).to eq('2001:db8::1')
    end

    it 'accepts IPv6 ranges with prefix' do
      expect(types::HetznerIpv6['2001:db8::/32']).to eq('2001:db8::/32')
    end

    it 'rejects clearly invalid IPv6' do
      expect { types::HetznerIpv6['not-ipv6'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerImageName' do
    it 'accepts valid image names' do
      expect(types::HetznerImageName['ubuntu-22.04']).to eq('ubuntu-22.04')
      expect(types::HetznerImageName['debian-12']).to eq('debian-12')
      expect(types::HetznerImageName['rocky-9']).to eq('rocky-9')
    end

    it 'rejects image names with invalid characters' do
      expect { types::HetznerImageName['Ubuntu 22.04'] }.to raise_error(Dry::Types::ConstraintError)
      expect { types::HetznerImageName['image@latest'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerPlacementGroupType' do
    it 'accepts spread' do
      expect(types::HetznerPlacementGroupType['spread']).to eq('spread')
    end

    it 'rejects other types' do
      expect { types::HetznerPlacementGroupType['cluster'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerLoadBalancerProtocol' do
    it 'accepts http, https, and tcp' do
      %w[http https tcp].each do |proto|
        expect(types::HetznerLoadBalancerProtocol[proto]).to eq(proto)
      end
    end

    it 'rejects invalid protocols' do
      expect { types::HetznerLoadBalancerProtocol['udp'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerSubnetType' do
    it 'accepts cloud, server, and vswitch' do
      %w[cloud server vswitch].each do |t|
        expect(types::HetznerSubnetType[t]).to eq(t)
      end
    end

    it 'rejects invalid subnet types' do
      expect { types::HetznerSubnetType['private'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerLabels' do
    it 'coerces symbol keys to strings' do
      result = types::HetznerLabels[{ env: 'prod', team: 'infra' }]
      expect(result).to eq({ 'env' => 'prod', 'team' => 'infra' })
    end

    it 'passes string keys through unchanged' do
      result = types::HetznerLabels[{ 'env' => 'prod' }]
      expect(result).to eq({ 'env' => 'prod' })
    end

    it 'defaults to an empty frozen hash' do
      result = types::HetznerLabels[]
      expect(result).to eq({})
      expect(result).to be_frozen
    end
  end

  describe 'HetznerDnsRecordType' do
    it 'accepts all valid DNS record types' do
      %w[A AAAA NS MX CNAME RP TXT SOA HINFO SRV DANE TLSA DS CAA].each do |rt|
        expect(types::HetznerDnsRecordType[rt]).to eq(rt)
      end
    end

    it 'rejects invalid record types' do
      expect { types::HetznerDnsRecordType['PTR'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerDnsZoneTtl' do
    it 'defaults to 86400' do
      result = types::HetznerDnsZoneTtl[]
      expect(result).to eq(86400)
    end

    it 'accepts valid TTL values' do
      expect(types::HetznerDnsZoneTtl[60]).to eq(60)
      expect(types::HetznerDnsZoneTtl[3600]).to eq(3600)
      expect(types::HetznerDnsZoneTtl[86400]).to eq(86400)
    end

    it 'rejects TTL below minimum (60)' do
      expect { types::HetznerDnsZoneTtl[59] }.to raise_error(Dry::Types::ConstraintError)
    end

    it 'rejects TTL above maximum (86400)' do
      expect { types::HetznerDnsZoneTtl[86401] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerDnsRecordTtl' do
    it 'accepts valid TTL range' do
      expect(types::HetznerDnsRecordTtl[60]).to eq(60)
      expect(types::HetznerDnsRecordTtl[86400]).to eq(86400)
    end

    it 'rejects out-of-range TTL' do
      expect { types::HetznerDnsRecordTtl[30] }.to raise_error(Dry::Types::ConstraintError)
      expect { types::HetznerDnsRecordTtl[100_000] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerPemCertificate' do
    let(:valid_cert) do
      "-----BEGIN CERTIFICATE-----\nMIIBxx...fake...base64\n-----END CERTIFICATE-----"
    end

    it 'accepts a valid PEM certificate' do
      expect(types::HetznerPemCertificate[valid_cert]).to eq(valid_cert)
    end

    it 'rejects a certificate missing the BEGIN header' do
      expect {
        types::HetznerPemCertificate['just some random text\n-----END CERTIFICATE-----']
      }.to raise_error(Dry::Types::ConstraintError, /PEM format/)
    end

    it 'rejects a certificate missing the END footer' do
      expect {
        types::HetznerPemCertificate['-----BEGIN CERTIFICATE-----\ndata without end']
      }.to raise_error(Dry::Types::ConstraintError, /PEM format/)
    end

    it 'rejects an empty string' do
      expect { types::HetznerPemCertificate[''] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerPemPrivateKey' do
    it 'accepts RSA private key' do
      key = "-----BEGIN RSA PRIVATE KEY-----\nfakedata\n-----END RSA PRIVATE KEY-----"
      expect(types::HetznerPemPrivateKey[key]).to eq(key)
    end

    it 'accepts EC private key' do
      key = "-----BEGIN EC PRIVATE KEY-----\nfakedata\n-----END EC PRIVATE KEY-----"
      expect(types::HetznerPemPrivateKey[key]).to eq(key)
    end

    it 'accepts PKCS8 private key' do
      key = "-----BEGIN PRIVATE KEY-----\nfakedata\n-----END PRIVATE KEY-----"
      expect(types::HetznerPemPrivateKey[key]).to eq(key)
    end

    it 'accepts encrypted private key' do
      key = "-----BEGIN ENCRYPTED PRIVATE KEY-----\nfakedata\n-----END ENCRYPTED PRIVATE KEY-----"
      expect(types::HetznerPemPrivateKey[key]).to eq(key)
    end

    it 'rejects non-PEM key data' do
      expect { types::HetznerPemPrivateKey['not a pem key'] }.to raise_error(Dry::Types::ConstraintError, /PEM format/)
    end
  end

  describe 'HetznerVolumeSize' do
    it 'accepts minimum size (10 GB)' do
      expect(types::HetznerVolumeSize[10]).to eq(10)
    end

    it 'accepts maximum size (10000 GB)' do
      expect(types::HetznerVolumeSize[10000]).to eq(10000)
    end

    it 'rejects sizes below minimum' do
      expect { types::HetznerVolumeSize[9] }.to raise_error(Dry::Types::ConstraintError)
    end

    it 'rejects sizes above maximum' do
      expect { types::HetznerVolumeSize[10001] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  describe 'HetznerSnapshotType' do
    it 'accepts snapshot' do
      expect(types::HetznerSnapshotType['snapshot']).to eq('snapshot')
    end

    it 'rejects invalid types' do
      expect { types::HetznerSnapshotType['backup'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end
end
