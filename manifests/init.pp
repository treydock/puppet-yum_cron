# == Class: yum_cron: See README.md for documentation
class yum_cron (
  $ensure                 = 'present',
  $enable                 = true,
  $download_updates       = true,
  $apply_updates          = false,
  # EL7/EL6 only options
  $debug_level            = $yum_cron::params::debug_level,
  $randomwait             = $yum_cron::params::randomwait,
  $mailto                 = 'root',
  $systemname             = $::fqdn,
  # EL6 only options
  $days_of_week           = '0123456',
  $cleanday               = '0',
  # EL7 only options
  $update_cmd             = 'default',
  $update_messages        = 'yes',
  $email_host             = 'localhost',
  # Misc configs
  $extra_configs          = {},
  # Scientific Linux configs
  $yum_autoupdate_ensure  = 'disabled',
  # Package, Service and Config params
  $package_ensure         = undef,
  $package_name           = $yum_cron::params::package_name,
  $service_name           = $yum_cron::params::service_name,
  $service_ensure         = undef,
  $service_enable         = undef,
  $service_hasstatus      = $yum_cron::params::service_hasstatus,
  $service_hasrestart     = $yum_cron::params::service_hasrestart,
  $config_path            = $yum_cron::params::config_path,
) inherits yum_cron::params {

  validate_bool(
    $enable,
    $download_updates,
    $apply_updates
  )
  validate_string(
    $mailto,
    $systemname,
    $days_of_week,
    $cleanday,
    $update_cmd,
    $update_messages,
    $email_host
  )
  validate_hash(
    $extra_configs
  )
  validate_re($yum_autoupdate_ensure, ['^undef', '^UNSET', '^absent', '^disabled'])

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
      fail("Module ${module_name}: ensure parameter must be present or absent, ${ensure} given")
    }
  }

  $package_ensure_real = pick($package_ensure, $package_ensure_default)
  $service_ensure_real = pick($service_ensure, $service_ensure_default)
  $service_enable_real = pick($service_enable, $service_enable_default)

  if $apply_updates {
    $apply_updates_str  = 'yes'
    $check_only         = 'no'
  } else {
    $apply_updates_str  = 'no'
    $check_only         = 'yes'
  }

  if $download_updates {
    $download_updates_str = 'yes'
    $download_only        = 'yes'
  } else {
    $download_updates_str = 'no'
    $download_only        = 'no'
  }

  include yum_cron::install
  include yum_cron::config
  include yum_cron::service

  anchor { 'yum_cron::start': }->
  Class['yum_cron::install']->
  Class['yum_cron::config']->
  Class['yum_cron::service']->
  anchor { 'yum_cron::end': }
}
