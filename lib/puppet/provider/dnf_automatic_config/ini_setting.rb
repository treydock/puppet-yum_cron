Puppet::Type.type(:dnf_automatic_config).provide(
  :ini_setting,
  parent: Puppet::Type.type(:ini_setting).provider(:ruby),
) do
  desc 'dnf_automatic_config provider'

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
    '/etc/dnf/automatic.conf'
  end
end
