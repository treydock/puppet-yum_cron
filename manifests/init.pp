# @summary Manage yum-cron
#
# @param ensure
#   Defines the presence of `yum-cron`.
#   Valid values are 'present' and 'absent'.  Default is `'present'`.
# @param enable
#   Boolean that defines the state of `yum-cron`.  Default is `true`
# @param download_updates
#   Boolean that determines if updates should be automatically downloaded.  Default is `true`
# @param apply_updates
#   Boolean that determines if updates should be automatically installed.  Default is `false`.
#   If set to `true` then `download_updates` ignored.
# @param debug_level
#   Sets debug level.  Default varies based on OS version
#   Applies only to EL7 and EL6.
# @param randomwait
#   Sets random wait time.  Default varies based on OS version
#   Applies only to EL7 and EL6.
# @param mailto
#   Address notified about updates.  Default is 'root'
#   Applies only to EL7 and EL6.
# @param systemname
#   Name of system used in notifications.  Default is `$::fqdn`
#   Applies only to EL7 and EL6.
# @param days_of_week
#   Days of the week that yum-cron will run.  Default is `'0123456'`
#   Applies only to EL6.
# @param cleanday
#   Day of the week yum-cron will cleanup.  Default is '0'
#   Applies only to EL6.
# @param update_cmd
#   The kind of updates to use.  Default is 'default'
#   Applies only to EL7.
#   Valid values:
#   * default                            = yum upgrade
#   * security                           = yum --security upgrade
#   * security-severity:Critical         = yum --sec-severity=Critical upgrade
#   * minimal                            = yum --bugfix upgrade-minimal
#   * minimal-security                   = yum --security upgrade-minimal
#   * minimal-security-severity:Critical =  --sec-severity=Critical upgrade-minimal
# @param update_messages
#   Determines whether a message should be emitted when updates are available, downloaded, and applied.  Default is 'yes'
#   Applies only to EL7.
# @param email_host
#   Host used to send email messages.  Default is 'localhost'
#   Applies only to EL7.
# @param extra_configs
#   Hash that can be used to define additional configurations.  Default is {}
#   Applies only to EL7 and EL6.
#
#   The Hash is passed to `create_resources`.
#   For EL7 the hash defines additional `yum_cron_config` resources.
#   For EL6 the hash defines additional `shellvar` resources.
# @param extra_hourly_configs
#   Hash that can be used to define additional hourly configurations.  Default is {}
#   Applies only to EL7.
#
#   The Hash is passed to `create_resources`.
#   For EL7 the hash defines additional `yum_cron_hourly_config` resources.
# @param yum_autoupdate_ensure
#   Defines how to handle yum-autoupdate on Scientific Linux systems.  Default is 'disabled'
#   Applies only to Scientific Linux.
#   Valid values:
#   * 'disabled' (default) - Sets ENABLED='false' in /etc/sysconfig/yum-autoupdate.
#   * 'absent' - Uninstall the yum-autoupdate package.
#   * 'undef' or 'UNSET' - Leave yum-autoupdate unmanaged.
# @param package_ensure
#   The ensure value passed to yum-cron package resource.  Default is `undef`
#   When `undef`, the value passed to the package resources is based on this class' `ensure` parameter value.
# @param package_name
#   yum-cron package name.  Default is `'yum-cron'`
# @param service_name
#   yum-cron service name.  Default is `'yum-cron'`
# @param service_ensure
#   The ensure value passed to yum-cron service resource.  Default is `undef`
#   When `undef`, the value passed to the service resources is based on this class' `ensure` and `enable` parameter values.
# @param service_enable
#   The ensure value passed to yum-cron package resource.  Default is `undef`
#   When `undef`, the value passed to the service resources is based on this class' `ensure` and `enable` parameter values.
# @param service_hasstatus
#   Service hasstatus property.  Default is `true`
# @param service_hasrestart
#   Service hasrestart property.  Default is `true`
# @param config_path
#   Path to yum-cron configuration.  Default is based on OS version.
#
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
  Hash $extra_hourly_configs = {},
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
