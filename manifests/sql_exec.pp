define echoes_alert::sql_exec (
  $branch = 'master',
  $source = ''
) {
  require postgresql::server

  file { $title:
    source => "puppet:///modules/${module_name}/postgresql/probe_sql_script/${branch}/${source}"
  }->
  exec { "psql -f ${title} echoes":
    path => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    user => 'postgres'
  }->
  exec { "rm -f ${title}":
    path => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
  }
}
