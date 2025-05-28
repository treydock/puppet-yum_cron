# frozen_string_literal: true

def defaults(release, key)
  d = {
    7 => {
      'package' => 'yum-cron',
      'config' => '/etc/yum/yum-cron.conf',
      'service' => 'yum-cron',
    },
    'default' => {
      'package' => 'dnf-automatic',
      'config' => '/etc/dnf/automatic.conf',
      'service' => 'dnf-automatic.timer',
    },
  }
  d.fetch(release, d['default'])[key]
end
