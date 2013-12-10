# == Class: yum_cron
#
# Manage yum-cron.
#
# === Parameters
#
# [*yum_parameter*]
#   String. Additional yum arguments.
#   Default: ''
#
# [*check_only*]
#   String. Sets yum-cron to only check for updates.
#   Valid values are 'yes' and 'no'.
#   Default: 'yes'
#
# [*check_first*]
#   String.  Valid values are 'yes' and 'no'.
#   Default: 'no'
#
# [*download_only*]
#   String.  Valid values are 'yes' and 'no'.
#   Default: 'no'
#
# [*error_level*]
#   String or Integer.
#   Default: 0
#
# [*debug_level*]
#   String or Integer.
#   Default: 0
#
# [*randomwait*]
#   String or Integer.
#   Default: '60'
#
# [*mailto*]
#   String. Address to send yum-cron update notifications.
#   Default: 'root'
#
# [*systemname*]
#   String.  Defaults to fqdn fact.
#
# [*days_of_week*]
#   String.  Days of the week to perform yum update checks.
#   Default: '0123456'
#
# [*cleanday*]
#   String.
#   Default: '0'
#
# [*service_waits*]
#   String.
#   Default: 'yes'
#
# [*service_wait_time*]
#   String or Integer.
#   Default: '300'
#
# [*package_name*]
#   String. Name of the yum-cron package.
#   Default: 'yum-cron'
#
# [*service_name*]
#   String. Name of the yum-cron service.
#   Default: 'yum-cron'
#
# [*service_ensure*]
#   Service ensure parameter.
#   Default: 'running'
#
# [*service_enable*]
#   Service enable parameter.
#   Default: true
#
# [*service_hasstatus*]
#   Service hasstatus parameter.
#
# [*service_hasrestart*]
#   Service hasrestart parameter.
#
# [*service_autorestart*]
#   Boolean.
#   Default: true
#
# [*config_path*]
#   Path to the yum-cron configuration file.
#   Default: '/etc/sysconfig/yum-cron'
#
# [*yum_autoupdate_ensure*]
#   String.  Valid values are 'undef', 'UNSET', 'absent', 'disabled'.
#     'absent' will uninstall the yum-autoupdate package.
#     'disabled' will set ENABLED="false" in /etc/sysconfig/yum-autoupdate.
#     'undef' and 'UNSET' will do nothing.
#   This is specific to Scientific Linux.
#   Default: 'disabled'
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
  $yum_parameter          = '',
  $check_only             = 'yes',
  $check_first            = 'no',
  $download_only          = 'no',
  $error_level            = 0,
  $debug_level            = 0,
  $randomwait             = '60',
  $mailto                 = 'root',
  $systemname             = $::fqdn,
  $days_of_week           = '0123456',
  $cleanday               = '0',
  $service_waits          = 'yes',
  $service_wait_time      = '300',
  $package_name           = $yum_cron::params::package_name,
  $service_name           = $yum_cron::params::service_name,
  $service_ensure         = 'running',
  $service_enable         = true,
  $service_hasstatus      = $yum_cron::params::service_hasstatus,
  $service_hasrestart     = $yum_cron::params::service_hasrestart,
  $service_autorestart    = true,
  $config_path            = $yum_cron::params::config_path,
  $yum_autoupdate_ensure  = 'disabled'
) inherits yum_cron::params {

  validate_re($check_only, ['^yes', '^no'])
  validate_re($check_first, ['^yes', '^no'])
  validate_re($download_only, ['^yes', '^no'])
  validate_bool($service_autorestart)
  validate_re($yum_autoupdate_ensure, ['^undef', '^UNSET', '^absent', '^disabled'])

  # This gives the option to not manage the service 'ensure' state.
  $service_ensure_real  = $service_ensure ? {
    /UNSET|undef/ => undef,
    default       => $service_ensure,
  }

  # This gives the option to not manage the service 'enable' state.
  $service_enable_real  = $service_enable ? {
    /UNSET|undef/ => undef,
    default       => $service_enable,
  }

  $service_subscribe = $service_autorestart ? {
    true  => File['/etc/sysconfig/yum-cron'],
    false => undef,
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
    subscribe   => $service_subscribe,
  }

  file { '/etc/sysconfig/yum-cron':
    ensure  => present,
    path    => $config_path,
    content => template('yum_cron/yum-cron.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Service['yum-cron'],
  }

  if $::operatingsystem =~ /Scientific/ {
    if $yum_autoupdate_ensure == 'absent' {
      package { 'yum-autoupdate':
        ensure  => absent,
      }
    }

    if $yum_autoupdate_ensure == 'disabled' {
      shellvar { 'disable yum-autoupdate':
        variable  => 'ENABLED',
        value     => 'false',
        target    => '/etc/sysconfig/yum-autoupdate',
      }
    }
  }
}
