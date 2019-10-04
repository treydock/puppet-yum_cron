# @summary Define module defaults
# @api private
class yum_cron::params {

  case $::osfamily {
    'RedHat': {
      $service_hasstatus  = true
      $service_hasrestart = true

      case $::operatingsystemmajrelease {
        '8': {
          $package_name     = 'dnf-automatic'
          $service_name     = 'dnf-automatic.timer'
          $config_path      = '/etc/dnf/automatic.conf'
          $debug_level      = '-2'
          $randomwait       = '360'
        }
        '7': {
          $package_name     = 'yum-cron'
          $service_name     = 'yum-cron'
          $config_path      = '/etc/yum/yum-cron.conf'
          $debug_level      = '-2'
          $randomwait       = '360'
        }
        '6': {
          $package_name     = 'yum-cron'
          $service_name     = 'yum-cron'
          $config_path      = '/etc/sysconfig/yum-cron'
          $debug_level      = '0'
          $randomwait       = '60'
        }
        default: {
          fail("Unsupported operatingsystemmajrelease: ${::operatingsystemmajrelease}, module ${module_name} only support 6 and 7")
        }
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
