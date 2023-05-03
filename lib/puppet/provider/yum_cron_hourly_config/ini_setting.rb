# frozen_string_literal: true

Puppet::Type.type(:yum_cron_hourly_config).provide(
  :ini_setting,
  parent: Puppet::Type.type(:ini_setting).provider(:ruby),
) do
  desc 'yum_cron_hourly_config provider'

  def section
    resource[:name].split('/', 2).first
  end

  def setting
    resource[:name].split('/', 2).last
  end

  def separator
    ' = '
  end

  def self.file_path
    '/etc/yum/yum-cron-hourly.conf'
  end
end
