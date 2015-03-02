# Private class
class yum_cron::params {

  case $::osfamily {
    'RedHat': {
      $package_name       = 'yum-cron'
      $service_name       = 'yum-cron'
      $service_hasstatus  = true
      $service_hasrestart = true

      case $::operatingsystemmajrelease {
        '7': {
          $config_path      = '/etc/yum/yum-cron.conf'
          $debug_level      = '-2'
          $randomwait       = '360'
        }
        '6': {
          $config_path      = '/etc/sysconfig/yum-cron'
          $debug_level      = '0'
          $randomwait       = '60'
        }
        '5': {
          $config_path      = '/etc/sysconfig/yum-cron'
          $debug_level      = undef
          $randomwait       = undef
        }
        default: {
          fail("Unsupported operatingsystemmajrelease: ${::operatingsystemmajrelease}, module ${module_name} only support 5, 6, and 7")
        }
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}