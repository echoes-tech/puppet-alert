class echoes_alert::api (
  $branch            = $echoes_alert::params::branch,
  $version           = $echoes_alert::params::version,
  $servername        = $echoes_alert::params::api_host,
  $serveralias       = $echoes_alert::params::serveralias,
  $port              = $echoes_alert::params::http_port,
  $ssl               = true,
  $ssl_port          = $echoes_alert::params::https_port,
  $database_host     = $echoes_alert::params::database_host,
  $database_name     = $echoes_alert::params::database_name,
  $database_user     = $echoes_alert::params::database_user,
  $database_password = $echoes_alert::params::database_password,
  $addons            = $echoes_alert::params::addons
) inherits echoes_alert::params {
  validate_string($branch)
  validate_string($version)
  validate_string($servername)
  validate_array($serveralias)
  #validate_re($port, '^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$')
  validate_bool($ssl)
  #validate_re($ssl_port, '^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$')
  validate_string($database_host)
  validate_string($database_name)
  validate_string($database_user)
  validate_string($database_password)
  validate_hash($addons)

  require echoes_alert::dbo
  #require apache
  require apache::mod::rewrite
  require apache::mod::fcgid

  if ($ssl)
  {
    require apache::mod::ssl
    require openssl
    apache::vhost { "${$servername}-ssl":
      servername    => $servername,
      port          => $ssl_port,
      serveradmin   => 'webmaster@echoes-tech.com',
      serveraliases => $serveraliases,
      ssl           => true,
      ssl_cert      => '/etc/ssl/echoes-tech.com/cert-echoes-tech.com.crt',
      ssl_key       => '/etc/ssl/echoes-tech.com/echoes-tech.com.key',
      ssl_ca        => '/etc/ssl/echoes-tech.com/GandiStandardSSLCA.pem',
      docroot       => '/var/www/wt',
      directories   => {
        path    => '/var/www/wt',
        options => '+ExecCGI +FollowSymLinks -Indexes',
      },
      rewrite_rule  => '^(.*)$ /api.wt/$1 [L]',
    }
    firewall { '100 allow API HTTPs access':
      port  => [ $ssl_port ],
      proto => 'tcp',
      jump  => 'allowed',
    }->
    firewall { '100 allow API HTTPs access:IPv6':
      port     => [ $ssl_port ],
      proto    => 'tcp',
      jump     => 'allowed',
      provider => 'ip6tables',
    }
    $redirect_dest = "https://${servername}:$ssl_port"
  } else {
    $redirect_dest = undef
  }

  apache::vhost { $servername:
    port            => $port,
    serveradmin     => 'webmaster@echoes-tech.com',
    serveraliases   => $serveraliases,
    #redirect_status => 'permanent',
    #redirect_dest   => $redirect_dest,
    docroot         => '/var/www/wt',
    directories     => {
      path    => '/var/www/wt',
      options => '+ExecCGI +FollowSymLinks -Indexes',
    },
    rewrite_rule    => '^(.*)$ /api.wt/$1 [L]',
  }
  firewall { '100 allow API HTTP access':
    port  => [ $port ],
    proto => 'tcp',
    jump  => 'allowed',
  }->
  firewall { '100 allow API HTTP access:IPv6':
    port     => [ $port ],
    proto    => 'tcp',
    jump     => 'allowed',
    provider => 'ip6tables',
  }

  file { '/var/www/wt/api.wt':
    ensure => file,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/api/${branch}/${version}/api",
  }

  file { '/var/www/wt/probe':
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
    require => File['/var/www/wt']
  }->
  file { '/var/www/wt/probe/core':
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    source  => "puppet:///modules/${module_name}/probe/core/${branch}/${version}",
    recurse => true,
    purge   => true,
    links   => follow,
  }
  file { '/var/www/wt/probe/addons':
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
    require => File['/var/www/wt/probe']
  }
  create_resources(addon, $addons)
}
