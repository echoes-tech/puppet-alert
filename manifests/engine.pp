class echoes_alert::engine (
  $branch            = $echoes_alert::params::branch,
  $version           = $echoes_alert::params::version,
  $install_dir       = "${echoes_alert::params::install_dir}/engine",
  $log_dir           = $echoes_alert::params::log_dir,
  $database_host     = $echoes_alert::params::database_host,
  $database_name     = $echoes_alert::params::database_name,
  $database_user     = $echoes_alert::params::database_user,
  $database_password = $echoes_alert::params::database_password,
  $api_host          = $echoes_alert::params::api_host,
  $api_port          = $echoes_alert::params::https_port,
  $api_https         = true,
) inherits echoes_alert::params {
  validate_string($branch)
  validate_string($version)
  validate_string($database_host)
  validate_string($database_name)
  validate_string($database_user)
  validate_string($database_password)

  require echoes_alert::dbo

  $libboost_name    = 'libboost'
  $libboost_version = '1.49.0'
  package { "${libboost_name}-serialization${libboost_version}":
    ensure => 'present'
  }
  package { 'openssl':
    ensure => 'latest',
  }
  package { 'sec':
    ensure => 'latest',
  }

  $service_name = 'ea-engine'
  $bin_file     = "${install_dir}/bin/${service_name}"
  $config_file  = "${install_dir}/etc/engine.conf"
  $default_file = "/etc/default/${service_name}"
  $init_file    = "/etc/init.d/${service_name}"
  $logrotate_file = "/etc/logrotate.d/${service_name}"
  $monit_file     = "/etc/monit/conf.d/${service_name}"

  file { $bin_file:
    ensure => 'file',
    owner  => 0,
    group  => 0,
    mode   => '0755',
    source => "puppet:///modules/${module_name}/engine/${branch}/${version}/engine",
  }

  file { $config_file:
    ensure  => 'file',
    owner   => 0,
    group   => 0,
    mode    => '0644',
    content => template("${module_name}/engine/${branch}/${version}/engine.conf.erb"),
  }

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

  file { "${install_dir}/etc":
    ensure => 'directory',
    owner  => 0,
    group  => 0,
    mode   => '0755'
  }

  file { $default_file:
    ensure  => 'file',
    owner   => 0,
    group   => 0,
    mode    => '0644',
    content => template("${module_name}/engine/${branch}/${version}${default_file}"),
  }

  file { $init_file:
    ensure  => file,
    owner   => 0,
    group   => 0,
    mode    => '0755',
    content => template("${module_name}/engine/${branch}/${version}${init_file}.erb"),
  }

  file { $logrotate_file:
    ensure => 'file',
    owner  => 0,
    group  => 0,
    mode   => '0644',
    source => "puppet:///modules/${module_name}/engine/${branch}/${version}${logrotate_file}",
  }

  monit::check { $service_name:
    content => template("${module_name}/engine/${branch}/${version}${monit_file}.erb"),
  }

  file { "${log_dir}/engine.log":
    ensure => 'file',
    owner  => 0,
    group  => 0,
    mode   => '0644'
  }

  service { $service_name:
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => [ File[$bin_file], File[$config_file], File[$default_file], File[$init_file] ],
  }

}
