class echoes_alert::simulator (
  $servername  = $echoes_alert::params::simulator_host,
  $serveralias = $echoes_alert::params::serveralias,
  $port        = $echoes_alert::params::http_port,
) inherits echoes_alert::params {
  #validate_re($port, '^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$')

  class { 'apache':
    default_vhost    => false,
    server_tokens    => 'Prod',
    server_signature => 'Off',
    trace_enable     => 'Off',
    mpm_module       => 'prefork'
  }

  require apache::mod::php

  $simulator_dir = '/var/www/simulator'

  apache::vhost { $servername:
    port          => $port,
    serveradmin   => 'webmaster@echoes-tech.com',
    serveraliases => $serveraliases,
    docroot       => $simulator_dir,
    directories   => {
      path    => $simulator_dir,
      options => '+ExecCGI +FollowSymLinks -Indexes',
    },
  }->
  file { $simulator_dir:
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    #source  => "puppet:///modules/${module_name}/simulator/${simulator_branch}/${simulator_version}",
    source  => "puppet:///modules/${module_name}/simulator/master/latest",
    ignore  => 'valeurs.txt',
    recurse => true,
    purge   => true,
    links   => follow,
  }->
  file { "${simulator_dir}/valeurs.txt":
    ensure => file,
    owner  => 'www-data',
    group  => 'www-data',
  }

  firewall { '100 allow Simulator HTTP access':
    port  => [ $port ],
    proto => 'tcp',
    jump  => 'allowed',
  }->
  firewall { '100 allow Simulator HTTP access:IPv6':
    port     => [ $port ],
    proto    => 'tcp',
    jump     => 'allowed',
    provider => 'ip6tables',
  }
}
