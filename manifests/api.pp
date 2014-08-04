class echoes_alert::api (
  $branch            = $echoes_alert::params::branch,
  $version           = $echoes_alert::params::version,
  $install_dir       = "${echoes_alert::params::install_dir}/api",
  $log_dir           = $echoes_alert::params::log_dir,
  $servername        = $echoes_alert::params::api_host,
  $port              = $echoes_alert::params::http_port,
  $ssl               = true,
  $ssl_port          = $echoes_alert::params::https_port,
  $database_host     = $echoes_alert::params::database_host,
  $database_name     = $echoes_alert::params::database_name,
  $database_user     = $echoes_alert::params::database_user,
  $database_password = $echoes_alert::params::database_password,
  $addons            = $echoes_alert::params::addons
) inherits echoes_alert::params {
  validate_string($branch, $version, $install_dir)
  validate_string($servername)
  #validate_re($port, '^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$')
  validate_bool($ssl)
  #validate_re($ssl_port, '^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$')
  validate_string($database_host, $database_name, $database_user, $database_password)
  validate_hash($addons)

  require echoes_alert::dbo

  $libboost_name    = 'libboost'
  $libboost_version = '1.49.0'
  package { "${libboost_name}-program-options${libboost_version}":
    ensure => 'present'
  }

  $service_name   = 'ea-api'
  $bin_file       = "${install_dir}/bin/${service_name}"
  $default_file   = "/etc/default/${service_name}"
  $init_file      = "/etc/init.d/${service_name}"
  $logrotate_file = "/etc/logrotate.d/${service_name}"
  $probe_dir      = "${install_dir}/probe"

  file { $install_dir:
    ensure => 'directory',
    owner  => 0,
    group  => 0,
    mode   => '0755'
  }

  file { "${install_dir}/bin":
    ensure => 'directory',
    owner  => 0,
    group  => 0,
    mode   => '0755'
  }

  file { $bin_file:
    ensure => 'file',
    owner  => 0,
    group  => 0,
    mode   => '0755',
    source => "puppet:///modules/${module_name}/api/${branch}/${version}/api",
  }

  file { $probe_dir:
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
  }
  file { "${probe_dir}/core":
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    source  => "puppet:///modules/${module_name}/probe/core/${branch}/${version}",
    recurse => true,
    purge   => true,
    links   => follow,
  }
  file { "${probe_dir}/addons":
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    mode    => '0644',
  }
  create_resources(addon, $addons)

  file { $default_file:
    ensure  => 'file',
    owner   => 0,
    group   => 0,
    mode    => '0644',
    content => template("${module_name}/api/${branch}/${version}${default_file}.erb"),
  }

  file { $init_file:
    ensure  => file,
    owner   => 0,
    group   => 0,
    mode    => '0755',
    content => template("${module_name}/api/${branch}/${version}${init_file}.erb"),
  }

  file { $logrotate_file:
    ensure => 'file',
    owner  => 0,
    group  => 0,
    mode   => '0644',
    source => "puppet:///modules/${module_name}/api/${branch}/${version}${logrotate_file}",
  }

  service { $service_name:
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => File[$init_file],
    subscribe  => [ File[$bin_file], File[$default_file], File[$init_file] ],
  }

  if $ssl
  {
    require openssl
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
}
