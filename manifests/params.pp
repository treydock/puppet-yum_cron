# == Class: yum_cron::params
#
# The yum_cron configuration settings.
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
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class yum_cron::params {

  $service_ensure       = 'running'
  $service_enable       = true
  $service_autorestart  = true

  case $::osfamily {
    'RedHat': {
      $package_name       = 'yum_cron'
      $service_name       = 'yum_cron'
      $service_hasstatus  = true
      $service_hasrestart = true
      $config_path        = '/etc/yum_cron'
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}