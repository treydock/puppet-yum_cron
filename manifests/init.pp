# == Class: yum_cron
#
# Full description of class yum_cron here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { yum_cron: }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class yum_cron (
$package_name         = $yum_cron::params::package_name,
$service_name         = $yum_cron::params::service_name,
$service_ensure       = $yum_cron::params::service_ensure,
$service_enable       = $yum_cron::params::service_enable,
$service_hasstatus    = $yum_cron::params::service_hasstatus,
$service_hasrestart   = $yum_cron::params::service_hasrestart,
$service_autorestart  = $yum_cron::params::service_autorestart,
$config_path          = $yum_cron::params::config_path
) inherits yum_cron::params {

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

  $service_subscribe = $service_autorestart ? {
    true  => File['/etc/yum_cron'],
    false => undef,
  }

  package { 'yum_cron':
    ensure  => present,
    name    => $package_name,
    before  => File['/etc/yum_cron'],
  }

  service { 'yum_cron':
    ensure      => $service_ensure_real,
    enable      => $service_enable_real,
    name        => $service_name,
    hasstatus   => $service_hasstatus,
    hasrestart  => $service_hasrestart,
    subscribe   => $service_subscribe,
  }

  file { '/etc/yum_cron':
    ensure  => present,
    path    => $config_path,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

}
