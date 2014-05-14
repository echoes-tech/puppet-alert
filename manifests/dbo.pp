class echoes_alert::dbo (
  $branch  = $echoes_alert::params::branch,
  $version = $echoes_alert::params::version,
) inherits echoes_alert::params {
  validate_string($branch)
  validate_string($version)

  require echoes_alert::wt

  package { 'libpq5':
    ensure => 'present',
    tag    => 'postgresql',
  }

  file { '/usr/local/lib/libdbo.so':
    ensure => 'file',
    owner  => 0,
    group  => 'staff',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/dbo/${branch}/${version}/libdbo.so",
  }
}
