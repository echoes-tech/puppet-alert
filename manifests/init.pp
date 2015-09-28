class echoes_alert (
  $api                 = $echoes_alert::params::api,
  $api_http_port       = $echoes_alert::params::api_http_port,
  $api_https           = $echoes_alert::params::api_https,
  $api_https_port      = $echoes_alert::params::api_https_port,
  $api_probe_addons    = $echoes_alert::params::api_probe_addons,
  $api_probe_branch    = $branch,
  $api_probe_version   = $version,
  $branch              = $echoes_alert::params::branch,
  $gui                 = $echoes_alert::params::gui,
  $gui_http_port       = $echoes_alert::params::gui_http_port,
  $gui_https           = $echoes_alert::params::gui_https,
  $gui_https_port      = $echoes_alert::params::gui_https_port,
  $gui_api_host        = $echoes_alert::params::gui_api_host,
  $gui_api_https       = $echoes_alert::params::gui_api_https,
  $gui_api_port        = $echoes_alert::params::gui_api_port,
  $database_host       = $echoes_alert::params::database_host,
  $database_name       = $echoes_alert::params::database_name,
  $database_user       = $echoes_alert::params::database_user,
  $database_password   = $echoes_alert::params::database_password,
  $engine              = $echoes_alert::params::engine,
  $engine_api_host     = $echoes_alert::params::engine_api_host,
  $engine_api_https    = $echoes_alert::params::engine_api_https,
  $engine_api_port     = $echoes_alert::params::engine_api_port,
  $install_dir         = $echoes_alert::params::install_dir,
  $log_dir             = $echoes_alert::params::log_dir,
  $manage_firewall     = $echoes_alert::params::manage_firewall,
  $postgresql          = $echoes_alert::params::postgresql,
  $postgresql_ipv4acls = $echoes_alert::params::postgresql_ipv4acls,
  $rsyslog             = $echoes_alert::params::rsyslog,
  $rsyslog_port        = $echoes_alert::params::rsyslog_port,
  $smtp_host           = $echoes_alert::params::smtp_host
  $version             = $echoes_alert::params::version,
) inherits echoes_alert::params {
  validate_bool($api)
  validate_bool($gui)
  validate_bool($engine)
  validate_bool($postgresql)
  validate_bool($rsyslog)

  anchor { "${module_name}::begin": } ->
  class { "${module_name}::install": } ->
  class { "${module_name}::config": } ~>
  class { "${module_name}::service": } ->
  anchor { "${module_name}::end": }
}
