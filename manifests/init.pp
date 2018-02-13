# == Class: yum_cron: See README.md for documentation
class yum_cron (
  Enum['present', 'absent'] $ensure = 'present',
  Boolean $enable = true,
  Boolean $download_updates = true,
  Boolean $apply_updates = false,
  # EL7/EL6 only options
  Pattern[/^(?:-)?[0-9]$/] $debug_level = $yum_cron::params::debug_level,
  Pattern[/^[0-9]+$/] $randomwait = $yum_cron::params::randomwait,
  String $mailto = 'root',
  String $systemname = $::fqdn,
  # EL6 only options
  Pattern[/^[0-6]+$/] $days_of_week = '0123456',
  Pattern[/^[0-6]$/] $cleanday = '0',
  # EL7 only options
  Yum_cron::Update_cmd $update_cmd = 'default',
  Enum['yes','no'] $update_messages = 'yes',
  String $email_host = 'localhost',
  # Misc configs
  Hash $extra_configs = {},
  # Scientific Linux configs
  Enum['undef', 'UNSET', 'absent', 'disabled'] $yum_autoupdate_ensure  = 'disabled',
  # Package, Service and Config params
  Optional[String] $package_ensure = undef,
  String $package_name = $yum_cron::params::package_name,
  String $service_name = $yum_cron::params::service_name,
  Optional[String] $service_ensure = undef,
  Optional[Boolean] $service_enable = undef,
  Boolean $service_hasstatus = $yum_cron::params::service_hasstatus,
  Boolean $service_hasrestart = $yum_cron::params::service_hasrestart,
  Stdlib::Absolutepath $config_path = $yum_cron::params::config_path,
) inherits yum_cron::params {

  case $ensure {
    'present': {
      $package_ensure_default   = 'present'
      if $enable {
        $service_ensure_default = 'running'
        $service_enable_default = true
        $config_notify          = Service['yum-cron']
      } else {
        $service_ensure_default = 'stopped'
        $service_enable_default = false
        $config_notify          = undef
      }
    }
    'absent': {
      $package_ensure_default = 'absent'
      $service_ensure_default = 'stopped'
      $service_enable_default = false
      $config_notify          = undef
    }
    default: {
      # Do nothing
    }
  }

  $package_ensure_real = pick($package_ensure, $package_ensure_default)
  $service_ensure_real = pick($service_ensure, $service_ensure_default)
  $service_enable_real = pick($service_enable, $service_enable_default)

  if $apply_updates {
    $apply_updates_str    = 'yes'
    $download_updates_str = 'yes'
    $check_only           = 'no'
    $download_only        = 'no'
  } else {
    $apply_updates_str  = 'no'
    $check_only         = 'yes'

    if $download_updates {
      $download_updates_str = 'yes'
      $download_only        = 'yes'
    } else {
      $download_updates_str = 'no'
      $download_only        = 'no'
    }
  }

  contain yum_cron::install
  contain yum_cron::config
  contain yum_cron::service

  Class['yum_cron::install']
  -> Class['yum_cron::config']
  -> Class['yum_cron::service']
}
