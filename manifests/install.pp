# @summary Install yum-cron
# @api private
class yum_cron::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  package { 'yum-cron':
    ensure => $yum_cron::package_ensure_real,
    name   => $yum_cron::package_name,
  }

  if $::operatingsystem =~ /Scientific/ and $yum_cron::yum_autoupdate_ensure == 'absent' {
    package { 'yum-autoupdate':
      ensure  => absent,
    }
  }
}
