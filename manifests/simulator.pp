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

  apache::vhost { $servername:
    port            => $port,
    serveradmin     => 'webmaster@echoes-tech.com',
    serveraliases   => $serveraliases,
    docroot         => '/var/www/simulator',
    directories     => {
      path    => '/var/www/wt',
      options => '+ExecCGI +FollowSymLinks -Indexes',
    },
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
