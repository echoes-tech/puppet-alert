class echoes_alert::pgxc
(
  $branch                   = $echoes_alert::params::branch,
  $version                  = $echoes_alert::params::version,
  $dbname                   = $echoes_alert::params::postgresql_dbname,
  $user                     = $echoes_alert::params::postgresql_user,
  $password                 = $echoes_alert::params::postgresql_password,
  $ipv4acls                 = $echoes_alert::params::postgresql_ipv4acls,
  $other_database_hostname  = '',
  $other_database_ip        = '',
  $database                 = $postgres_xc::params::database,
  $gtm_hostname             = $postgres_xc::params::gtm_hostname,
  $gtm_standby_hostname     = $postgres_xc::params::gtm_standby_hostname,
) inherits echoes_alert::params {
  validate_string($branch)
  validate_string($version)
  validate_string($dbname)
  validate_string($user)
  validate_string($password)

  class { 'postgres_xc::database':
    other_database_hostname => $other_database_hostname,
    other_database_ip       => $other_database_ip,
    gtm_hostname            => $gtm_hostname,
    gtm_standby_hostname    => $gtm_standby_hostname,
    database_name           => $dbname,
    user                    => $user,
    password                => $password,
    acl_db                  => $ipv4acls,
  }

  file { 'dir_facter':
    ensure    => 'directory',
    path      => '/etc/facter',
    owner     => 'root',
    group     => 'root',
    mode      => '0655'
  }->

  file { 'dir_probe_sql_script_last_num':
    ensure    => 'directory',
    path      => '/etc/facter/facts.d',
    owner     => 'root',
    group     => 'root',
    mode      => '0655'
  }->

  file { 'probe_sql_script_last_num':
    ensure    => 'present',
    path      => '/etc/facter/facts.d/probe_sql_script_last_num.txt',
    source    => "puppet:///modules/echoes_alert/probe_sql_script_last_num_${::hostname}.txt"
  }

  create_resources(sql_exec, sql_archive('/etc/puppet/environments/production/modules/echoes_alert/files/postgresql/probe_sql_script', $branch))
}
