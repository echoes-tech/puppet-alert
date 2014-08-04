# == Class: echoes_alert
#
# This module manages ECHOES Alert.
#
# === Parameters
#
# [*branch*]
#   Select the Git branch.
#   Default: master
#
# [*version*]
#   Select the jobs number of Jenkins. Must be a integer or latest.
#   Default: latest
#
# === Variables
#
# === Examples
#
#  class { echoes_alert:
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
class echoes_alert (
  $branch              = $echoes_alert::params::branch,
  $version             = $echoes_alert::params::version,
  $install_dir         = $echoes_alert::params::install_dir,
  $log_dir             = $echoes_alert::params::log_dir,
  $postgresql          = false,
  $postgresql_ipv4acls = $echoes_alert::params::postgresql_ipv4acls,
  $database_host       = $echoes_alert::params::database_host,
  $database_name       = $echoes_alert::params::database_name,
  $database_user       = $echoes_alert::params::database_user,
  $database_password   = $echoes_alert::params::database_password,
  $api                 = false,
  $api_host            = $echoes_alert::params::api_host,
  $api_serveralias     = $echoes_alert::params::serveralias,
  $api_port            = $echoes_alert::params::http_port,
  $api_ssl             = true,
  $api_ssl_port        = $echoes_alert::params::https_port,
  $api_addons          = $echoes_alert::params::addons,
  $gui                 = false,
  $gui_host            = $echoes_alert::params::gui_host,
  $gui_serveralias     = $echoes_alert::params::serveralias,
  $gui_port            = $echoes_alert::params::http_port,
  $gui_ssl             = true,
  $gui_ssl_port        = $echoes_alert::params::https_port,
  $gui_api_host        = $api_host,
  $gui_api_port        = $api_ssl_port,
  $engine              = false,
  $engine_api_host     = $api_host,
  $engine_api_port     = $api_ssl_port,
  $rsyslog             = false,
  $rsyslog_port        = $echoes_alert::params::https_port,
  $smtp_host           = $echoes_alert::params::smtp_host
) inherits echoes_alert::params {
  validate_bool($postgresql)
  validate_bool($api)
  validate_bool($gui)
  validate_bool($engine)
  validate_bool($rsyslog)

  if $postgresql {
    class { 'echoes_alert::postgresql':
      branch   => $branch,
      version  => $version,
      dbname   => $database_name,
      user     => $database_user,
      password => $database_password,
      ipv4acls => $postgresql_ipv4acls,
    }
  }
  if $api or $gui or $engine or $rsyslog {
    class { 'echoes_alert::wt':
      branch            => $branch,
      version           => $version,
      api               => $api,
      gui               => $gui,
      api_host          => $gui_api_host,
      api_port          => $gui_api_port,
      database_host     => $database_host,
      database_name     => $database_name,
      database_user     => $database_user,
      database_password => $database_password,
      smtp_host         => $smtp_host,
    }
    class { 'echoes_alert::dbo':
      branch  => $branch,
      version => $version,
    }

    file { $install_dir:
      ensure => 'directory',
      owner  => 0,
      group  => 0,
      mode   => '0755'
    }

    file { $log_dir:
      ensure => 'directory',
      owner  => 0,
      group  => 0,
      mode   => '0755'
    }
 
    if $api or $gui {
      if $api_ssl or $gui_ssl {
        $domain = 'echoes-tech.com'
        $cert_bundle = "/etc/ssl/${domain}/bundle-${domain}.crt"
        class { 'openssl':
          domains => {
            'echoes-tech.com' => {
              domain => 'echoes-tech.com'
            },
          },
        }->
        concat { $cert_bundle:
           owner => 0,
           group => 'ssl-cert',
           mode  => '0640',
        }
        concat::fragment { "cert ${domain}":
           target => $cert_bundle,
           source => "/etc/ssl/${domain}/cert-${domain}.crt",
           order  => 01,
        }
        concat::fragment { "New Line":
           target  => $cert_bundle,
           content => "\n",
           order   => 10
        }
        concat::fragment { "Gandi CA cert":
           target => $cert_bundle,
           source => "/etc/ssl/${domain}/GandiStandardSSLCA.pem",
           order   => 15
        }
        exec { 'openssl dhparam -check -text -5 1024 -out /etc/ssl/dh1024.pem':
          path    => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
          creates => '/etc/ssl/dh1024.pem',
        }
        #ToDo: Improve this
        exec { "chmod 600 /etc/ssl/${domain}/${domain}.key":
          path    => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
          unless  => "[ $(stat -c %a /etc/ssl/${domain}/${domain}.key) == 600 ]",
          require => Class[ 'openssl']
        } 
      }

      file { '/tmp/exim4-config.preseed':
        source => "puppet:///modules/${module_name}/exim4-config.preseed",
        mode   => '0600',
        backup => false,
      }->
      package { 'exim4-daemon-light':
        ensure       => 'present',
        responsefile => '/tmp/exim4-config.preseed',
        require      => File['/tmp/exim4-config.preseed'],
      }->
      file { '/etc/exim4/exim4.conf.localmacros':
        source => "puppet:///modules/${module_name}/exim4.conf.localmacros",
        owner  => 0
      }->
      file { '/etc/exim4/passwd.client':
        source => "puppet:///modules/${module_name}/passwd.client",
        mode   => '0640',
        owner  => 0,
        group  => 'Debian-exim'
      }->
      service { 'exim4':
        ensure    => 'running',
        subscribe =>  [ File['/etc/exim4/exim4.conf.localmacros'], File['/etc/exim4/passwd.client'] ]
      }
      if $api {
        class { 'echoes_alert::api':
          branch            => $branch,
          version           => $version,
          install_dir       => "${install_dir}/api",
          log_dir           => $log_dir,
          servername        => $api_host,
          port              => $api_port,
          ssl               => $api_ssl,
          ssl_port          => $api_ssl_port,
          database_host     => $database_host,
          database_name     => $database_name,
          database_user     => $database_user,
          database_password => $database_password,
          addons            => $api_addons
        }
      }
      if $gui {
        class { 'echoes_alert::gui':
          branch            => $branch,
          version           => $version,
          install_dir       => "${install_dir}/gui",
          log_dir           => $log_dir,
          servername        => $gui_host,
          port              => $gui_port,
          ssl               => $gui_ssl,
          ssl_port          => $gui_ssl_port,
          database_host     => $database_host,
          database_name     => $database_name,
          database_user     => $database_user,
          database_password => $database_password,
        }
      }
    }
    if $engine {
      class { 'echoes_alert::engine':
        branch            => $branch,
        version           => $version,
        install_dir       => "${install_dir}/engine",
        log_dir           => $log_dir,
        database_host     => $database_host,
        database_name     => $database_name,
        database_user     => $database_user,
        database_password => $database_password,
        api_host          => $engine_api_host,
        api_port          => $engine_api_port,
      }
    }
    if $rsyslog {
      class { 'openssl':
        domains => {
          'echoes-tech.com' => {
            domain => 'echoes-tech.com'
          },
        },
      }

      class { 'echoes_alert::rsyslog':
        branch            => $branch,
        version           => $version,
        install_dir       => "${install_dir}/rsyslog",
        log_dir           => $log_dir,
        port              => $rsyslog_port,
        database_host     => $database_host,
        database_name     => $database_name,
        database_user     => $database_user,
        database_password => $database_password,
      }
    }
  }
}
