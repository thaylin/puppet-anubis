# anubis Puppet module

This module manages one or more Anubis instances from a hash of instance definitions.

## Usage

```puppet
include anubis
```

Configure instances via Hiera (`data/common.yaml` example included):

```yaml
anubis::instances:
  default:
    basedir: /etc/anubis
    env:
      ANUBIS_LISTEN: 0.0.0.0:8080
    policy_hash:
      version: v1
      rules:
        - path: /
          action: authenticate
```

## Classes and defined types

- `class anubis` - iterates `instances` hash and declares `anubis::instance` resources.
- `define anubis::instance` - manages per-instance env and policy files.

## Templates

- `templates/env.epp` - renders `KEY=value` environment file.
- `templates/policy_raw.epp` - renders raw policy content.
- `templates/policy_from_hash.epp` - renders YAML from a Puppet hash.
