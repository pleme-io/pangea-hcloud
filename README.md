# pangea-hcloud

Hetzner Cloud provider bindings for the Pangea infrastructure DSL.

## Overview

Provides 25 typed Terraform resource functions for Hetzner Cloud, covering servers,
SSH keys, firewalls, networks, subnets, load balancers, floating IPs, volumes,
certificates, placement groups, snapshots, and DNS zones. Each resource uses
Dry::Struct validation and compiles to Terraform JSON via terraform-synthesizer.
Built on pangea-core.

## Installation

```ruby
gem 'pangea-hcloud', '~> 0.1'
```

## Usage

```ruby
require 'pangea-hcloud'

template :compute do
  provider :hcloud do
    token var(:hcloud_token)
  end

  key = hcloud_ssh_key(:deployer, { name: "deployer", public_key: var(:ssh_pub) })
  hcloud_server(:node, { name: "node-1", server_type: "cx22", image: "ubuntu-24.04", ssh_keys: [key.id] })
end
```

## Development

```bash
nix develop
bundle exec rspec
```

## License

Apache-2.0
