# @summary Manage yum-cron configs
# @api private
class yum_cron::config {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  case String($facts['os']['release']['major']) {
    '2', '7': {
      Yum_cron_config {
        notify => $yum_cron::config_notify,
      }

      yum_cron_config { 'commands/update_cmd': value => $yum_cron::update_cmd }
      yum_cron_config { 'commands/update_messages': value => $yum_cron::update_messages }
      yum_cron_config { 'commands/download_updates': value => $yum_cron::download_updates_str }
      yum_cron_config { 'commands/apply_updates': value => $yum_cron::apply_updates_str }
      yum_cron_config { 'commands/random_sleep': value => $yum_cron::randomwait }
      yum_cron_config { 'emitters/system_name': value => $yum_cron::systemname }
      yum_cron_config { 'emitters/emit_via': value => $yum_cron::emit_via }
      yum_cron_config { 'email/email_from': value => $yum_cron::mailfrom }
      yum_cron_config { 'email/email_to': value => $yum_cron::mailto }
      yum_cron_config { 'email/email_host': value => $yum_cron::email_host }
      yum_cron_config { 'base/debuglevel': value => $yum_cron::debug_level }
      yum_cron_config { 'base/exclude':
        ensure => $yum_cron::exclude_packages_ensure,
        value  => join($yum_cron::exclude_packages, ' '),
      }

      $yum_cron::extra_configs.each |$name, $res| {
        yum_cron_config { $name: * => $res }
      }
      $yum_cron::extra_hourly_configs.each |$name, $res| {
        yum_cron_hourly_config { $name: * => $res }
      }
    }
    default: {
      Dnf_automatic_config {
        notify => $yum_cron::config_notify,
      }

      dnf_automatic_config { 'commands/upgrade_type': value => $yum_cron::upgrade_type }
      dnf_automatic_config { 'commands/upgrade_cmd': ensure => 'absent' }
      dnf_automatic_config { 'commands/update_messages': ensure => 'absent' }
      dnf_automatic_config { 'commands/download_updates': value => $yum_cron::download_updates_str }
      dnf_automatic_config { 'commands/apply_updates': value => $yum_cron::apply_updates_str }
      dnf_automatic_config { 'commands/random_sleep': value => $yum_cron::randomwait }
      dnf_automatic_config { 'commands/reboot': value => $yum_cron::reboot }
      dnf_automatic_config { 'commands/reboot_command': value => "\"${yum_cron::reboot_command}\"" }
      dnf_automatic_config { 'emitters/system_name': value => $yum_cron::systemname }
      dnf_automatic_config { 'emitters/emit_via': value => $yum_cron::emit_via }
      dnf_automatic_config { 'email/email_from': value => $yum_cron::mailfrom }
      dnf_automatic_config { 'email/email_to': value => $yum_cron::mailto }
      dnf_automatic_config { 'email/email_host': value => $yum_cron::email_host }
      dnf_automatic_config { 'base/debuglevel': value => $yum_cron::debug_level }
      dnf_automatic_config { 'base/exclude':
        ensure => $yum_cron::exclude_packages_ensure,
        value  => join($yum_cron::exclude_packages, ' '),
      }

      $yum_cron::extra_configs.each |$name, $res| {
        dnf_automatic_config { $name: * => $res }
      }
    }
  }

  if $facts['os']['name'] =~ /Scientific/ and $yum_cron::yum_autoupdate_ensure == 'disabled' {
    file_line { 'disable yum-autoupdate':
      path  => '/etc/sysconfig/yum-autoupdate',
      line  => 'ENABLED=false',
      match => '^ENABLED=.*',
    }
  }
}
