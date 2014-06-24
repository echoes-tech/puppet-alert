define echoes_alert::addon (
  $branch  = 'master',
  $version = 'latest'
) {
  validate_string($branch)
  validate_string($version)

  file { "/var/www/wt/probe/addons/${title}":
    ensure  => directory,
    owner   => 'www-data',
    group   => 'www-data',
    source  => "puppet:///modules/${module_name}/probe/addons/${title}/${branch}/${version}",
    recurse => true,
    purge   => true,
    links   => follow,
    require => File ['/var/www/wt/probe/addons']
  }
}
