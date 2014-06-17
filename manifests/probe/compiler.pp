# == Class: compiler
#
# This module manages the probe compiler for ECHOES Technologies.
#
#   Tested platforms:
#    - Debian 6.0 Squeeze
#    - Debian 7.0 Wheezy
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { echoes_alert::probe::compiler:
#  }
#
# === Authors
#
# Florent Poinsaut <florent.poinsaut@echoes-tech.com>
#
# === Copyright
#
# Copyright 2014 ECHOES Technologies SAS, unless otherwise noted.
#
class echoes_alert::probe::compiler (
  $requirements = {},
) {
  validate_array($requirements)

  file {'/etc/ld.so.conf.d/libc.conf':
    ensure  => 'file',
    content => '# libc default configuration
/usr/local/lib'
  }->
  file {'/tmp/puppet_package.rb':
    ensure  => 'file',
    content => template("${module_name}/probe/puppet_package.rb.erb"),
  }->
  exec {'Script Execution':
    command => 'ruby /tmp/puppet_package.rb',
    path    => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    timeout => 0
  }
}
