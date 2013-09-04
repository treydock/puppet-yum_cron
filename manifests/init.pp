# == Class: yum_cron
#
# Manage yum-cron.
#
# === Parameters
#
# === Examples
#
#  class { 'yum_cron': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class yum_cron (
  $yum_parameter        = '',
  $check_only           = 'yes',
  $check_first          = 'no',
  $download_only        = 'no',
  $error_level          = 0,
  $debug_level          = 1,
  $randomwait           = '60',
  $mailto               = '',
  $systemname           = '',
  $days_of_week         = '0123456',
  $cleanday             = '0',
  $service_waits        = 'yes',
  $service_wait_time    = '300',
  $package_name         = $yum_cron::params::package_name,
  $service_name         = $yum_cron::params::service_name,
  $service_ensure       = $yum_cron::params::service_ensure,
  $service_enable       = $yum_cron::params::service_enable,
  $service_hasstatus    = $yum_cron::params::service_hasstatus,
  $service_hasrestart   = $yum_cron::params::service_hasrestart,
  $config_path          = $yum_cron::params::config_path
) inherits yum_cron::params {

  validate_re($check_only, '^yes|no$')
  validate_re($check_first, '^yes|no$')
  validate_re($download_only, '^yes|no$')

  # This gives the option to not manage the service 'ensure' state.
  $service_ensure_real  = $service_ensure ? {
    'undef'   => undef,
    default   => $service_ensure,
  }

  # This gives the option to not manage the service 'enable' state.
  $service_enable_real  = $service_enable ? {
    'undef'   => undef,
    default   => $service_enable,
  }

  package { 'yum-cron':
    ensure  => present,
    name    => $package_name,
    before  => File['/etc/sysconfig/yum-cron'],
  }

  service { 'yum-cron':
    ensure      => $service_ensure_real,
    enable      => $service_enable_real,
    name        => $service_name,
    hasstatus   => $service_hasstatus,
    hasrestart  => $service_hasrestart,
    subscribe   => File['/etc/sysconfig/yum-cron'],
  }

  file { '/etc/sysconfig/yum-cron':
    ensure  => present,
    path    => $config_path,
    content => template('yum_cron/yum-cron.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }
}
