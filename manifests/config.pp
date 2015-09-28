# Private class
class echoes_alert::config inherits echoes_alert {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $echoes_alert::api or $echoes_alert::gui {
    file { '/etc/exim4/exim4.conf.localmacros':
      source => "puppet:///modules/${module_name}/exim4.conf.localmacros",
      owner  => 0
    }
    file { '/etc/exim4/passwd.client':
      source => "puppet:///modules/${module_name}/passwd.client",
      mode   => '0640',
      owner  => 0,
      group  => 'Debian-exim'
    }
  }

}
