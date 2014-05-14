class echoes_alert::rsyslog (
  $branch            = $echoes_alert::params::branch,
  $version           = $echoes_alert::params::version,
  $install_dir       = "${echoes_alert::params::install_dir}/rsyslog",
  $log_dir           = $echoes_alert::params::log_dir,
  $port              = $echoes_alert::params::https_port,
  $database_host     = $echoes_alert::params::database_host,
  $database_name     = $echoes_alert::params::database_name,
  $database_user     = $echoes_alert::params::database_user,
  $database_password = $echoes_alert::params::database_password
) inherits echoes_alert::params {
  validate_string($branch)
  validate_string($version)
  validate_string($database_host)
  validate_string($database_name)
  validate_string($database_user)
  validate_string($database_password)

  require echoes_alert::dbo
  class { '::rsyslog':
    gnutls => true,
  }

  $config_file     = '/etc/rsyslog.d/echoes-alert.conf'
  $bin_name        = 'ea-parser'
  $bin_file        = "${install_dir}/bin/${bin_name}"
  $bin_config_file = "${install_dir}/etc/${bin_name}.conf"

  firewall { '100 allow Rsyslog access':
    port  => [ $port ],
    proto => 'tcp',
    jump  => 'allowed'
  }->
  firewall { '100 allow Rsyslog access:IPv6':
    port     => [ $port ],
    proto    => 'tcp',
    jump     => 'allowed',
    provider => 'ip6tables'
  }

  file { $config_file:
    ensure  => 'file',
    owner   => 0,
    group   => 0,
    mode    => '0600',
    content => template("${module_name}/rsyslog/${branch}/${version}${config_file}.erb")
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

  file { $bin_file:
    ensure => 'file',
    owner  => 0,
    group  => 0,
    mode   => '0755',
    source => "puppet:///modules/${module_name}/rsyslog/${branch}/${version}/rsyslog"
  }

  file { $bin_config_file:
    ensure  => 'file',
    owner   => 0,
    group   => 0,
    mode    => '0644',
    content => template("${module_name}/rsyslog/${branch}/${version}/conf/ea-parser.conf.erb")
  }

  file { "${log_dir}/parser.log":
    ensure => 'file',
    owner  => 0,
    group  => 0,
    mode   => '0644'
  }
}
