class echoes_alert::gui (
  $branch            = $echoes_alert::params::branch,
  $version           = $echoes_alert::params::version,
  $install_dir       = "${echoes_alert::params::install_dir}/gui",
  $log_dir           = $echoes_alert::params::log_dir,
  $servername        = $echoes_alert::params::gui_host,
  $port              = $echoes_alert::params::http_port,
  $ssl               = true,
  $ssl_port          = $echoes_alert::params::https_port,
  $database_host     = $echoes_alert::params::database_host,
  $database_name     = $echoes_alert::params::database_name,
  $database_user     = $echoes_alert::params::database_user,
  $database_password = $echoes_alert::params::database_password,
) inherits echoes_alert::params {
  validate_string($branch, $version, $install_dir)
  validate_string($servername)
  #validate_re($port, '^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$')
  validate_bool($ssl)
  #validate_re($ssl_port, '^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$')
  validate_string($database_host, $database_name, $database_user, $database_password)

  require echoes_alert::dbo

  $service_name   = 'ea-gui'
  $bin_file       = "${install_dir}/bin/${service_name}"
  $default_file   = "/etc/default/${service_name}"
  $init_file      = "/etc/init.d/${service_name}"
  $logrotate_file = "/etc/logrotate.d/${service_name}"
  $monit_file     = "/etc/monit/conf.d/${service_name}"

  file { $install_dir:
    ensure => 'directory',
    owner  => 0,
    group  => 0,
    mode   => '0755',
  }

  file { "${install_dir}/bin":
    ensure => 'directory',
    owner  => 0,
    group  => 0,
    mode   => '0755',
  }

  file { "${install_dir}/css":
    ensure => 'directory',
    owner  => 0,
    group  => 0,
    mode   => '0644',
    recurse => true,
    purge   => true,
    source => "puppet:///modules/${module_name}/gui/${branch}/${version}/css",
  }

  file { "${install_dir}/images":
    ensure => 'directory',
    owner  => 0,
    group  => 0,
    mode   => '0644',
    recurse => true,
    purge   => true,
    source => "puppet:///modules/${module_name}/gui/${branch}/${version}/images",
  }

  file { "${install_dir}/resources":
    ensure => 'directory',
    owner  => 0,
    group  => 0,
    mode   => '0644',
    recurse => true,
    purge   => true,
    source => "puppet:///modules/${module_name}/gui/${branch}/${version}/resources",
  }

  file { "${install_dir}/favicon.ico":
    ensure => 'file',
    owner  => 0,
    group  => 0,
    mode   => '0644',
    source => "puppet:///modules/${module_name}/gui/${branch}/${version}/favicon.ico",
  }

  file { $bin_file:
    ensure => 'file',
    owner  => 0,
    group  => 0,
    mode   => '0755',
    source => "puppet:///modules/${module_name}/gui/${branch}/${version}/gui",
  }

  file { $default_file:
    ensure  => 'file',
    owner   => 0,
    group   => 0,
    mode    => '0644',
    content => template("${module_name}/gui/${branch}/${version}${default_file}.erb"),
  }

  file { $init_file:
    ensure  => file,
    owner   => 0,
    group   => 0,
    mode    => '0755',
    content => template("${module_name}/gui/${branch}/${version}${init_file}.erb"),
  }

  file { $logrotate_file:
    ensure => 'file',
    owner  => 0,
    group  => 0,
    mode   => '0644',
    source => "puppet:///modules/${module_name}/gui/${branch}/${version}${logrotate_file}",
  }

  file { $monit_file:
    ensure  => 'file',
    owner   => 0,
    group   => 0,
    mode    => '0644',
    content => template("${module_name}/gui/${branch}/${version}${monit_file}.erb"),
    notify  => Service['monit'],
  }

  service { $service_name:
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => File[$init_file],
    subscribe  => [ File[$bin_file], File[$default_file], File[$init_file] ],
  }

  if ($ssl)
  {
    require openssl
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
  }

  firewall { '100 allow GUI HTTP access':
    port  => [ $port ],
    proto => 'tcp',
    jump  => 'allowed',
  }->
  firewall { '100 allow GUII HTTP access:IPv6':
    port     => [ $port ],
    proto    => 'tcp',
    jump     => 'allowed',
    provider => 'ip6tables',
  }
}
