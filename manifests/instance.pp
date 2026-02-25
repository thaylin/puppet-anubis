define anubis::instance (
  Stdlib::Absolutepath $config_dir,

  String  $bind,
  Integer $difficulty,
  String  $metrics_bind,
  Variant[Integer, Boolean] $serve_robots,

  String  $target,
  String  $cookie_domain,

  Enum['raw','hash'] $policy_mode = 'raw',
  Optional[String]  $policy_raw   = undef,
  Optional[Hash]    $policy_hash  = undef,

  Enum['running','stopped'] $service_ensure = 'running',
  Boolean $service_enable = true,
) {
  $fqdn = $title

  $env_file    = "${config_dir}/${fqdn}.env"
  $policy_file = "${config_dir}/${fqdn}.botPolicies.yaml"

  # Basic validation so you don’t silently deploy garbage:
  if $policy_mode == 'raw' and $policy_raw == undef {
    fail("anubis::instance[${fqdn}] policy_mode is 'raw' but policy_raw is undef")
  }
  if $policy_mode == 'hash' and $policy_hash == undef {
    fail("anubis::instance[${fqdn}] policy_mode is 'hash' but policy_hash is undef")
  }

  file { $env_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp('anubis/env.epp', {
      'bind'          => $bind,
      'difficulty'    => $difficulty,
      'metrics_bind'  => $metrics_bind,
      'serve_robots'  => $serve_robots,
      'target'        => $target,
      'cookie_domain' => $cookie_domain,
      'policy_fname'  => $policy_file,
    }),
    require => File[$config_dir],
    notify  => Service["anubis@${fqdn}"],
  }

  if $policy_mode == 'raw' {
    file { $policy_file:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('anubis/policy_raw.epp', { 'policy_raw' => $policy_raw }),
      require => File[$config_dir],
      notify  => Service["anubis@${fqdn}"],
    }
  } else {
    file { $policy_file:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('anubis/policy_from_hash.epp', { 'policy' => $policy_hash }),
      require => File[$config_dir],
      notify  => Service["anubis@${fqdn}"],
    }
  }

  # Manage instance service
  service { "anubis@${fqdn}":
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasstatus  => true,
    hasrestart => true,
    require    => [
      File[$env_file],
      File[$policy_file],
    ],
  }
}
