# == Class: yum_cron::params
#
# The yum_cron configuration settings.
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class yum_cron::params {

  case $::osfamily {
    'RedHat': {
      $package_name       = 'yum-cron'
      $service_name       = 'yum-cron'
      $service_hasstatus  = true
      $service_hasrestart = true
      $config_path        = '/etc/sysconfig/yum-cron'
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}