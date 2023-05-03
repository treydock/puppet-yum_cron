# @summary Manage yum-cron
#
# @param ensure
#   Defines the presence of `yum-cron`.
# @param enable
#   Boolean that defines the state of `yum-cron`.
# @param download_updates
#   Boolean that determines if updates should be automatically downloaded.
# @param apply_updates
#   Boolean that determines if updates should be automatically installed.
#   If set to `true` then `download_updates` ignored.
# @param upgrade_type
#   The kind of updates to perform.
#   Applies only to EL8, EL9.
# @param debug_level
#   Sets debug level.
# @param exclude_packages
#   Packages to exclude from updates.
# @param randomwait
#   Sets random wait time.
# @param mailto
#   Address notified about updates.
# @param systemname
#   Name of system used in notifications.
# @param email_host
#   Host used to send email messages.
# @param update_cmd
#   The kind of updates to use.
#   Applies only to EL7.
#   Valid values:
#   * default                            = yum upgrade
#   * security                           = yum --security upgrade
#   * security-severity:Critical         = yum --sec-severity=Critical upgrade
#   * minimal                            = yum --bugfix upgrade-minimal
#   * minimal-security                   = yum --security upgrade-minimal
#   * minimal-security-severity:Critical =  --sec-severity=Critical upgrade-minimal
# @param update_messages
#   Determines whether a message should be emitted when updates are available, downloaded, and applied.
#   Applies only to EL7.
# @param extra_configs
#   Hash that can be used to define additional configurations.
#   Applies only to EL7, EL8, and EL9.
#
#   For EL8 and EL9 the hash defines additonal `dnf_automatic_config` resources.
#   For EL7 the hash defines additional `yum_cron_config` resources.
# @param extra_hourly_configs
#   Hash that can be used to define additional hourly configurations.
#   Applies only to EL7.
#
#   For EL7 the hash defines additional `yum_cron_hourly_config` resources.
# @param yum_autoupdate_ensure
#   Defines how to handle yum-autoupdate on Scientific Linux systems.
#   Applies only to Scientific Linux.
#   Valid values:
#   * 'disabled' (default) - Sets ENABLED='false' in /etc/sysconfig/yum-autoupdate.
#   * 'absent' - Uninstall the yum-autoupdate package.
#   * 'undef' or 'UNSET' - Leave yum-autoupdate unmanaged.
# @param package_ensure
#   The ensure value passed to yum-cron package resource.
#   When `undef`, the value passed to the package resources is based on this class' `ensure` parameter value.
# @param package_name
#   yum-cron package name.  Default is based on OS version.
# @param service_name
#   yum-cron service name.  Default is based on OS version.
# @param service_ensure
#   The ensure value passed to yum-cron service resource.
#   When `undef`, the value passed to the service resources is based on this class' `ensure` and `enable` parameter values.
# @param service_enable
#   The ensure value passed to yum-cron package resource.
#   When `undef`, the value passed to the service resources is based on this class' `ensure` and `enable` parameter values.
# @param service_hasstatus
#   Service hasstatus property.
# @param service_hasrestart
#   Service hasrestart property.
# @param config_path
#   Path to yum-cron configuration.  Default is based on OS version.
#
class yum_cron (
  String $package_name,
  String $service_name,
  Stdlib::Absolutepath $config_path,
  Enum['present', 'absent'] $ensure = 'present',
  Boolean $enable = true,
  Boolean $download_updates = true,
  Boolean $apply_updates = false,
  # EL8 only options
  Enum['default','security'] $upgrade_type = 'default',
  # EL8 and EL7 options
  Pattern[/^(?:-)?[0-9]$/] $debug_level = '-2',
  Pattern[/^[0-9]+$/] $randomwait = '360',
  Array $exclude_packages = [],
  String $mailto = 'root',
  String $systemname = $facts['networking']['fqdn'],
  String $email_host = 'localhost',
  # EL7 only options
  Yum_cron::Update_cmd $update_cmd = 'default',
  Enum['yes','no'] $update_messages = 'yes',
  # Misc configs
  Hash $extra_configs = {},
  Hash $extra_hourly_configs = {},
  # Scientific Linux configs
  Enum['undef', 'UNSET', 'absent', 'disabled'] $yum_autoupdate_ensure  = 'disabled',
  # Package, Service and Config params
  Optional[String] $package_ensure = undef,
  Optional[String] $service_ensure = undef,
  Optional[Boolean] $service_enable = undef,
  Boolean $service_hasstatus = true,
  Boolean $service_hasrestart = true,
) {
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

  if empty($exclude_packages) {
    $exclude_packages_ensure = 'absent'
  } else {
    $exclude_packages_ensure = 'present'
  }

  contain yum_cron::install
  contain yum_cron::service

  Class['yum_cron::install']
  -> Class['yum_cron::service']

  if $ensure == 'present' {
    contain yum_cron::config
    Class['yum_cron::install']
    -> Class['yum_cron::config']
    -> Class['yum_cron::service']
  }
}
