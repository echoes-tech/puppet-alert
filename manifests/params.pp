# == Class: echoes_alert::params
#
# This is a container class with default parameters for echoes_alert classes.
class echoes_alert::params {
  $api                 = true
  $api_http_port       = 8080
  $api_https           = true
  $api_http_port       = 8443
  $api_probe_addons    = {
    'common'     => {},
    'file'       => {},
    'filesystem' => {},
    'hash'       => {},
    'log'        => {},
    'odbc'       => {},
    'process'    => {},
    'snmp'       => {},
    'xml'        => {}
  }
  $branch              = 'master'
  $database_host       = '127.0.0.1'
  $database_name       = 'echoes'
  $database_user       = 'echoes'
  $database_password   = 'echoes'
  $gui                 = true
  $gui_api_host        = 'localhost'
  $gui_api_https       = false
  $gui_api_port        = $api_http_port
  $gui_http_port       = 80
  $gui_https           = true
  $gui_https_port      = 443
  $engine              = true
  $engine_api_host     = 'localhost'
  $engine_api_https    = false
  $engine_api_port     = $api_http_port
  $install_dir         = '/opt/echoes-alert'
  $log_dir             = '/var/log/echoes-alert'
  $manage_firewall     = true
  $postgresql          = true
  $postgresql_ipv4acls = []
  $rsyslog             = true
  $rsyslog_port        = 4443
  $simulator_host      = 'alert-simulator.echoes-tech.com'
  $smtp_host           = 'localhost'
  $version             = 'latest'
}
