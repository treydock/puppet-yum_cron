def defaults(release, key)
  d = {
    8 => {
      'package' => 'dnf-automatic',
      'config'  => '/etc/dnf/automatic.conf',
      'service' => 'dnf-automatic.timer',
    },
    'default' => {
      'package' => 'yum-cron',
      'config'  => '/etc/yum/yum-cron.conf',
      'service' => 'yum-cron',
    },
  }
  d.fetch(release, d['default'])[key]
end
