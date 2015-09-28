i# Private class
class echoes_alert::service inherits echoes_alert {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $echoes_alert::api or $echoes_alert::gui {
    service { 'exim4':
      ensure    => running,
      subscribe => File [ '/etc/exim4/exim4.conf.localmacros', '/etc/exim4/passwd.client' ]
    }
  }
}
