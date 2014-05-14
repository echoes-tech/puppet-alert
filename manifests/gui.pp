class echoes_alert::gui (
  $branch            = $echoes_alert::params::branch,
  $version           = $echoes_alert::params::version,
  $servername        = $echoes_alert::params::gui_host,
  $serveralias       = $echoes_alert::params::serveralias,
  $port              = $echoes_alert::params::http_port,
  $ssl               = true,
  $ssl_port          = $echoes_alert::params::https_port,
  $database_host     = $echoes_alert::params::database_host,
  $database_name     = $echoes_alert::params::database_name,
  $database_user     = $echoes_alert::params::database_user,
  $database_password = $echoes_alert::params::database_password,
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
      port          => 443,
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
      rewrite_cond  => [ '%{REQUEST_URI} !^/resources [NC]', '%{REQUEST_URI} !^/images [NC]' ],
      rewrite_rule  => '^(.*)$ /gui.wt/$1 [L]',
    }
    firewall { '100 allow GUI HTTPs access':
      port  => [ $ssl_port ],
      proto => 'tcp',
      jump  => 'allowed',
    }->
    firewall { '100 allow GUI HTTPs access:IPv6':
      port     => [ $ssl_port ],
      proto    => 'tcp',
      jump     => 'allowed',
      provider => 'ip6tables',
    }
    $redirect_dest = "https://${servername}"
  } else {
    $redirect_dest = undef
  }

  apache::vhost { $servername:
    port            => 80,
    serveradmin     => 'webmaster@echoes-tech.com',
    serveraliases   => $serveraliases,
    #redirect_status => 'permanent',
    #redirect_dest   => $redirect_dest,
    docroot         => '/var/www/wt',
    directories     => {
      path    => '/var/www/wt',
      options => '+ExecCGI +FollowSymLinks -Indexes',
    },
    rewrite_cond    => [ '%{REQUEST_URI} !^/resources [NC]', '%{REQUEST_URI} !^/images [NC]' ],
    rewrite_rule    => '^(.*)$ /gui.wt/$1 [L]',
  }
  firewall { '100 allow GUI HTTP access':
    port  => [ $port ],
    proto => 'tcp',
    jump  => 'allowed',
  }->
  firewall { '100 allow GUI HTTP access:IPv6':
    port     => [ $port ],
    proto    => 'tcp',
    jump     => 'allowed',
    provider => 'ip6tables',
  }

  file { '/var/www/wt':
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
    source  => "puppet:///modules/${module_name}/gui/${branch}/${version}",
    recurse => true,
    purge   => true,
    links   => follow,
    ignore  => [ 'gui', 'config.xml.erb', 'cppcheck-result.xml', 'cppncss.xml' ]
  }->
  file { '/var/www/wt/gui.wt':
    ensure => file,
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/gui/${branch}/${version}/gui",
  }
}
