class anubis (
  Boolean $manage_package = true,
  String  $package_name   = 'anubis',
  Boolean $manage_dir      = true,
  Stdlib::Absolutepath $config_dir = '/etc/anubis',

  Hash[String, Hash] $instances = lookup('anubis::instances', { default_value => {} }),
) {

  if $manage_package {
    package { $package_name:
      ensure => installed,
    }
  }

  if $manage_dir {
    file { $config_dir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
  }

  $instances.each |String $fqdn, Hash $cfg| {
    anubis::instance { $fqdn:
      config_dir     => $config_dir,

      bind           => pick($cfg['bind'], '0.0.0.0:8920'),
      difficulty     => pick($cfg['difficulty'], 4),
      metrics_bind   => pick($cfg['metrics_bind'], ':9090'),
      serve_robots   => pick($cfg['serve_robots_txt'], 0),

      target         => $cfg['target'],
      cookie_domain  => pick($cfg['cookie_domain'], $fqdn),

      # policy handling:
      policy_mode    => pick($cfg['policy_mode'], 'raw'), # 'raw' or 'hash'
      policy_raw     => pick($cfg['policy_raw'], undef),
      policy_hash    => pick($cfg['policy_hash'], undef),

      service_ensure => pick($cfg['service_ensure'], 'running'),
      service_enable => pick($cfg['service_enable'], true),
    }
  }
}
