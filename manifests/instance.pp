# Defined type: anubis::instance
#
# Configure a single Anubis instance and its rendered files.
#
# @param ensure
#   Whether to create resources for this instance.
# @param basedir
#   Base directory for instance content.
# @param env
#   Environment variables to render into env file.
# @param policy
#   Raw policy text. Mutually exclusive with policy_hash.
# @param policy_hash
#   Structured policy to render as YAML.
define anubis::instance (
  Enum['present', 'absent'] $ensure = 'present',
  Stdlib::Absolutepath $basedir = '/etc/anubis',
  Hash[String, Variant[String, Numeric, Boolean]] $env = {},
  Optional[String] $policy = undef,
  Optional[Hash] $policy_hash = undef,
) {
  if $policy and $policy_hash {
    fail('anubis::instance: policy and policy_hash are mutually exclusive')
  }

  $instance_dir = "${basedir}/${title}"
  $instance_env_file = "${instance_dir}/env"
  $instance_policy_file = "${instance_dir}/policy.yaml"

  file { $instance_dir:
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
  }

  if $ensure == 'present' {
    file { $instance_env_file:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => epp('anubis/env.epp', {'env' => $env}),
    }

    if $policy {
      file { $instance_policy_file:
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        content => epp('anubis/policy_raw.epp', {'policy' => $policy}),
      }
    } elsif $policy_hash {
      file { $instance_policy_file:
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        content => epp('anubis/policy_from_hash.epp', {'policy_hash' => $policy_hash}),
      }
    } else {
      file { $instance_policy_file:
        ensure => 'absent',
      }
    }
  } else {
    file { [$instance_env_file, $instance_policy_file]:
      ensure => 'absent',
    }
  }
}
