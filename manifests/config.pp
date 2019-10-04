# @summary Manage yum-cron configs
# @api private
class yum_cron::config {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $yum_cron::ensure == 'present' {
    if $::operatingsystemmajrelease == '8' {
      Dnf_automatic_config {
        notify => $yum_cron::config_notify,
      }

      dnf_automatic_config { 'commands/update_cmd': value => $yum_cron::update_cmd }
      dnf_automatic_config { 'commands/update_messages': value => $yum_cron::update_messages }
      dnf_automatic_config { 'commands/download_updates': value => $yum_cron::download_updates_str }
      dnf_automatic_config { 'commands/apply_updates': value => $yum_cron::apply_updates_str }
      dnf_automatic_config { 'commands/random_sleep': value => $yum_cron::randomwait }
      dnf_automatic_config { 'emitters/system_name': value => $yum_cron::systemname }
      dnf_automatic_config { 'email/email_to': value => $yum_cron::mailto }
      dnf_automatic_config { 'email/email_host': value => $yum_cron::email_host }
      dnf_automatic_config { 'base/debuglevel': value => $yum_cron::debug_level }

      create_resources(dnf_automatic_config, $yum_cron::extra_configs)
    }

    if $::operatingsystemmajrelease == '7' {
      Yum_cron_config {
        notify => $yum_cron::config_notify,
      }

      yum_cron_config { 'commands/update_cmd': value => $yum_cron::update_cmd }
      yum_cron_config { 'commands/update_messages': value => $yum_cron::update_messages }
      yum_cron_config { 'commands/download_updates': value => $yum_cron::download_updates_str }
      yum_cron_config { 'commands/apply_updates': value => $yum_cron::apply_updates_str }
      yum_cron_config { 'commands/random_sleep': value => $yum_cron::randomwait }
      yum_cron_config { 'emitters/system_name': value => $yum_cron::systemname }
      yum_cron_config { 'email/email_to': value => $yum_cron::mailto }
      yum_cron_config { 'email/email_host': value => $yum_cron::email_host }
      yum_cron_config { 'base/debuglevel': value => $yum_cron::debug_level }

      create_resources(yum_cron_config, $yum_cron::extra_configs)
      create_resources(yum_cron_hourly_config, $yum_cron::extra_hourly_configs)
    }

    if $::operatingsystemmajrelease < '7' {
      Shellvar {
        ensure => present,
        target => $yum_cron::config_path,
        notify => $yum_cron::config_notify,
      }

      shellvar { 'yum_cron CHECK_ONLY':
        variable => 'CHECK_ONLY',
        value    => $yum_cron::check_only,
      }

      shellvar { 'yum_cron DOWNLOAD_ONLY':
        variable => 'DOWNLOAD_ONLY',
        value    => $yum_cron::download_only,
      }

      if $::operatingsystemmajrelease == '6' {
        shellvar { 'yum_cron DEBUG_LEVEL':
          variable => 'DEBUG_LEVEL',
          value    => $yum_cron::debug_level,
        }

        shellvar { 'yum_cron RANDOMWAIT':
          variable => 'RANDOMWAIT',
          value    => $yum_cron::randomwait,
        }

        shellvar { 'yum_cron MAILTO':
          variable => 'MAILTO',
          value    => $yum_cron::mailto,
        }

        shellvar { 'yum_cron SYSTEMNAME':
          variable => 'SYSTEMNAME',
          value    => $yum_cron::systemname,
        }

        shellvar { 'yum_cron DAYS_OF_WEEK':
          variable => 'DAYS_OF_WEEK',
          value    => $yum_cron::days_of_week,
        }

        shellvar { 'yum_cron CLEANDAY':
          variable => 'CLEANDAY',
          value    => $yum_cron::cleanday,
        }

        create_resources(shellvar, $yum_cron::extra_configs)
      }
    }

    if $::operatingsystem =~ /Scientific/ and $yum_cron::yum_autoupdate_ensure == 'disabled' {
      file_line { 'disable yum-autoupdate':
        path  => '/etc/sysconfig/yum-autoupdate',
        line  => 'ENABLED=false',
        match => '^ENABLED=.*',
      }
    }
  }
}
