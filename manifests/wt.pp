class echoes_alert::wt (
  $branch            = $echoes_alert::params::branch,
  $version           = $echoes_alert::params::version,
  $api               = false,
  $gui               = false,
  $api_host          = $echoes_alert::params::api_host,
  $api_port          = $echoes_alert::params::https_port,
  $database_host     = $echoes_alert::params::database_host,
  $database_name     = $echoes_alert::params::database_name,
  $database_user     = $echoes_alert::params::database_user,
  $database_password = $echoes_alert::params::database_password,
  $smtp_host         = $echoes_alert::params::smtp_host
) inherits echoes_alert::params {
  validate_string($branch)
  validate_string($version)
  validate_bool($api)
  validate_bool($gui)
  validate_string($database_host)
  validate_string($database_name)
  validate_string($database_user)
  validate_string($database_password)
  validate_string($smtp_host)

  $libboost_name    = 'libboost'
  $libboost_version = '1.49.0'
  package { "${libboost_name}-thread${libboost_version}":
    ensure => 'present'
  }
  package { "${libboost_name}-random${libboost_version}":
    ensure => 'present'
  }
  package { "${libboost_name}-regex${libboost_version}":
    ensure => 'present'
  }
  package { "${libboost_name}-signals${libboost_version}":
    ensure => 'present'
  }
  package { "${libboost_name}-system${libboost_version}":
    ensure => 'present'
  }
  package { "${libboost_name}-filesystem${libboost_version}":
    ensure => 'present'
  }
  package { "${libboost_name}-date-time${libboost_version}":
    ensure => 'present'
  }

  file { '/usr/local/lib':
    ensure  => directory,
    owner   => 0,
    group   => 0,
    mode    => '0644',
    #source  => "puppet:///modules/${module_name}/wt/${branch}/${version}/lib",
    source  => "puppet:///modules/${module_name}/wt/${version}/lib",
    recurse => true
  }->
  exec { 'ldconfig':
    path        => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    refreshonly => true,
    subscribe   => File['/usr/local/lib'],
  }

  if $api or $gui {
    if $api {
      $sms_login    = "contact@echoes-tech.com"
      $sms_password = "00SjmAuiItooki"
    }

    file { '/etc/wt':
      ensure => directory,
      owner  => 0,
      group  => 0,
      mode   => '0644',
    }

    file { '/etc/wt/wt_config.xml':
      ensure  => file,
      owner   => 0,
      group   => 0,
      mode    => '0644',
      content => template("${module_name}/wt/wt_config.xml.erb")
    }

    file { '/etc/logrotate.d/wthttp':
      ensure => 'file',
      owner  => 0,
      group  => 0,
      mode   => '0644',
      source => "puppet:///modules/${module_name}/wthttp.logrotate",
    }
  }
}
