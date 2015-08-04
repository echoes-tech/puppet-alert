class echoes_alert::postgresql (
  $branch   = $echoes_alert::params::branch,
  $version  = $echoes_alert::params::version,
  $dbname   = $echoes_alert::params::postgresql_dbname,
  $user     = $echoes_alert::params::postgresql_user,
  $password = $echoes_alert::params::postgresql_password,
  $ipv4acls = $echoes_alert::params::postgresql_ipv4acls,
) inherits echoes_alert::params {
  validate_string($branch)
  validate_string($version)
  validate_string($dbname)
  validate_string($user)
  validate_string($password)
  validate_array($ipv4acls)

  class { 'postgresql::server':
    listen_addresses => '*',
    ipv4acls         => $ipv4acls,
  }

  postgresql::server::db { $dbname:
    user     => $user,
    password => postgresql_password($user, $password),
  }

  file { '/etc/facter':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644'
  }->
  file { '/etc/facter/facts.d':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644'
  }->
  file { '/etc/facter/facts.d/probe_sql_script_last_num.txt':
    ensure => present,
    source => "puppet:///modules/${module_name}/postgresql/probe_sql_script/last_num_${::hostname}.txt"
  }

  #create_resources(sql_exec, sql_archive("/etc/puppet/environments/production/modules/${module_name}/files/postgresql/probe_sql_script", $branch))
  create_resources(sql_exec, sql_archive("/etc/puppet/environments/production/modules/${module_name}/files/postgresql/probe_sql_script", 'develop'))
}
