define echoes_alert::addon (
  $branch  = 'master',
  $version = 'latest',
) {
  validate_string($branch, $version)

  file { "${echoes_alert::api::probe_dir}/addons/${title}":
    ensure  => directory,
    owner   => 0,
    group   => 0,
    source  => "puppet:///modules/${module_name}/probe/addons/${title}/${branch}/${version}",
    recurse => true,
    purge   => true,
    links   => follow,
  }
}
