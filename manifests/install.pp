# Private class
class echoes_alert::install inherits echoes_alert {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $echoes_alert::postgresql {
    class { 'echoes_alert_postgresql':
      branch      => $echoes_alert::branch,
      dbname      => $echoes_alert::database_name,
      user        => $echoes_alert::database_user,
      password    => $echoes_alert::database_password,
      ipv4acls    => $echoes_alert::postgresql_ipv4acls,
      version     => $echoes_alert::version,
    }
  }

#    if $api or $gui {
#      if $api_ssl or $gui_ssl {
#        $domain = 'echoes-tech.com'
#        $cert_bundle = "/etc/ssl/${domain}/bundle-${domain}.crt"
#        concat { $cert_bundle:
#          owner   => 0,
#          group   => 'ssl-cert',
#          mode    => '0640',
#          require => Class[ 'openssl' ],
#        }
#        concat::fragment { "cert ${domain}":
#          target => $cert_bundle,
#          source => "/etc/ssl/${domain}/cert-${domain}.crt",
#          order  => 01,
#        }
#        concat::fragment { 'New Line':
#          target  => $cert_bundle,
#          content => "\n",
#          order   => 10
#        }
#        concat::fragment { 'Gandi CA cert':
#          target => $cert_bundle,
#          source => "/etc/ssl/${domain}/GandiStandardSSLCA.pem",
#          order  => 15
#        }
#        exec { 'openssl dhparam -check -text -5 1024 -out /etc/ssl/dh1024.pem':
#          path    => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
#          creates => '/etc/ssl/dh1024.pem',
#        }
#        #ToDo: Improve this
#        exec { "chmod 600 /etc/ssl/${domain}/${domain}.key":
#          path    => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
#          unless  => "[ $(stat -c %a /etc/ssl/${domain}/${domain}.key) == 600 ]",
#          require => Class[ 'openssl']
#        }
#      }
#
#  }


  $boost_version = '1.49'

  if $echoes_alert::engine or $echoes_alert::api or $echoes_alert::gui or $echoes_alert::rsyslog {
    class { 'boost':
      packages => {
        'date-time'  => {},
        'filesystem' => {},
        'random'     => {},
        'regex'      => {},
        'signals'    => {},
        'system'     => {},
        'thread'     => {},
      },
      version  => $boost_version
    }

    class { 'echoes_alert_wt':
      libraries_path => "puppet:///modules/${module_name}/wt/develop/lib",
      use_package    => false,
    }->
    class { 'echoes_alert_dbo':
      branch  => $echoes_alert::branch,
      version => $echoes_alert::version,
    }

    file { $echoes_alert::install_dir:
      ensure => 'directory',
      owner  => 0,
      group  => 0,
      mode   => '0755'
    }

    file { $echoes_alert::log_dir:
      ensure => 'directory',
      owner  => 0,
      group  => 0,
      mode   => '0755'
    }
  }

  if $echoes_alert::api or $echoes_alert::engine or $echoes_alert::gui {
    boost::package { 'program-options':
      version  => $boost_version
    }

    class { 'monit':
      check_interval => 2,
    }
  }

  if $echoes_alert::api or $echoes_alert::gui or $echoes_alert::rsyslog {
    class { '::openssl':
      package_ensure         => latest,
      ca_certificates_ensure => latest,
    }
  }

  if $echoes_alert::api or $echoes_alert::gui {
    file { '/tmp/exim4-config.preseed':
      source => "puppet:///modules/${module_name}/exim4-config.preseed",
      mode   => '0600',
      backup => false,
    }->
    package { 'exim4-daemon-light':
      ensure       => 'present',
      responsefile => '/tmp/exim4-config.preseed',
    }
  }

  if $echoes_alert::api {
    class { 'echoes_alert_api':
      branch          => $echoes_alert::branch,
      http_port       => $echoes_alert::api_http_port,
      https           => $echoes_alert::api_https,
      https_port      => $echoes_alert::api_https_port,
      manage_firewall => $echoes_alert::manage_firewall,
      probe_addons    => $echoes_alert::api_probe_addons,
      probe_branch    => $echoes_alert::api_probe_branch,
      probe_version   => $echoes_alert::api_probe_version,
      version         => $echoes_alert::version,
    }
  }

  if $echoes_alert::gui {
    class { 'echoes_alert_gui':
      branch          => $echoes_alert::branch,
      http_port       => $echoes_alert::gui_http_port,
      https           => $echoes_alert::gui_https,
      https_port      => $echoes_alert::gui_https_port,
      manage_firewall => $echoes_alert::manage_firewall
      version         => $echoes_alert::version,
    }
  }

  if $echoes_alert::engine {
    boost::package { 'serialization':
      version => $boost_version
    }
    package { 'sec':
      ensure => 'latest',
    }
    class { 'echoes_alert_engine':
        api_host          => $echoes_alert::engine_api_host,
        api_https         => $echoes_alert::engine_api_https,
        api_port          => $echoes_alert::engine_api_port,
        branch            => $echoes_alert::branch,
        database_host     => $echoes_alert::database_host,
        database_name     => $echoes_alert::database_name,
        database_user     => $echoes_alert::database_user,
        database_password => $echoes_alert::database_password,
        version           => $echoes_alert::version,
    }
  }

  if $echoes_alert::rsyslog {
    class { 'echoes_alert_rsyslog':
      branch          => $echoes_alert::branch,
      port            => $echoes_alert::rsyslog_port,
      manage_firewall => $echoes_alert::manage_firewall
      version         => $echoes_alert::version,
    }
    }
  }

}
