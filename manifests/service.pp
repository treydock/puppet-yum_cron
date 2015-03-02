# Private class
class yum_cron::service {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  service { 'yum-cron':
    ensure     => $yum_cron::service_ensure_real,
    enable     => $yum_cron::service_enable_real,
    name       => $yum_cron::service_name,
    hasstatus  => $yum_cron::service_hasstatus,
    hasrestart => $yum_cron::service_hasrestart,
  }
}
