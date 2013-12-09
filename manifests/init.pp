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
#   String.
#   Default: ''
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
# [*config_path*]
#   Path to the yum-cron configuration file.
#
# [*disable_yum_autoupdate*]
#   Boolean.  Disables the yum-autoupdate service
#   that is specific to Scientific Linux.
#   Default: true
#
# [*remove_yum_autoupdate*]
#   Boolean.  Uninstalls the yum-autoupdate package
#   that is specific to Scientific Linux.
#   Default: false
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
  $systemname             = '',
  $days_of_week           = '0123456',
  $cleanday               = '0',
  $service_waits          = 'yes',
  $service_wait_time      = '300',
  $package_name           = $yum_cron::params::package_name,
  $service_name           = $yum_cron::params::service_name,
  $service_ensure         = $yum_cron::params::service_ensure,
  $service_enable         = $yum_cron::params::service_enable,
  $service_hasstatus      = $yum_cron::params::service_hasstatus,
  $service_hasrestart     = $yum_cron::params::service_hasrestart,
  $config_path            = $yum_cron::params::config_path,
  $disable_yum_autoupdate = true,
  $remove_yum_autoupdate  = false
) inherits yum_cron::params {

  validate_re($check_only, '^yes|no$')
  validate_re($check_first, '^yes|no$')
  validate_re($download_only, '^yes|no$')
  validate_bool($disable_yum_autoupdate)
  validate_bool($remove_yum_autoupdate)

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

  if $::operatingsystem =~ /Scientific/ {
    if $disable_yum_autoupdate and ! $remove_yum_autoupdate {
      shellvar { 'disable yum-autoupdate':
        variable  => 'ENABLED',
        value     => 'false',
        target    => '/etc/sysconfig/yum-autoupdate',
      }
    }

    if $remove_yum_autoupdate {
      package { 'yum-autoupdate':
        ensure  => absent,
      }
    }
  }
}
