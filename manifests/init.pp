# Class: anubis
#
# Manage one or more Anubis instances.
#
# @param instances
#   Hash of instance names to configuration hashes.
class anubis (
  Hash[String, Hash] $instances = {},
) {
  $instances.each |String $instance_name, Hash $instance_config| {
    anubis::instance { $instance_name:
      * => $instance_config,
    }
  }
}
