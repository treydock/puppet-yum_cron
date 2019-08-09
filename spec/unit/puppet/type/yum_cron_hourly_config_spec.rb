$LOAD_PATH.push(
  File.join(
    File.dirname(__FILE__),
    '..',
    '..',
    '..',
    'fixtures',
    'modules',
    'inifile',
    'lib',
  ),
)
require 'spec_helper'
require 'puppet/type/yum_cron_hourly_config'

describe 'Puppet::Type.type(:yum_cron_hourly_config)' do
  let(:yum_cron_hourly_config) do
    Puppet::Type.type(:yum_cron_hourly_config).new(name: 'vars/foo', value: 'bar')
  end

  it 'requires a name' do
    expect {
      Puppet::Type.type(:yum_cron_hourly_config).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'does not expect a name with whitespace' do
    expect {
      Puppet::Type.type(:yum_cron_hourly_config).new(name: 'f oo')
    }.to raise_error(Puppet::Error, %r{Invalid yum_cron_hourly_config})
  end

  it 'fails when there is no section' do
    expect {
      Puppet::Type.type(:yum_cron_hourly_config).new(name: 'foo')
    }.to raise_error(Puppet::Error, %r{Invalid yum_cron_hourly_config})
  end

  it 'does not require a value when ensure is absent' do
    Puppet::Type.type(:yum_cron_hourly_config).new(name: 'vars/foo', ensure: :absent)
  end

  it 'requires a value when ensure is present' do
    expect {
      Puppet::Type.type(:yum_cron_hourly_config).new(name: 'vars/foo', ensure: :present)
    }.to raise_error(Puppet::Error, %r{Property value must be set})
  end

  it 'accepts a valid value' do
    yum_cron_hourly_config[:value] = 'bar'
    expect(yum_cron_hourly_config[:value]).to eql('bar')
  end

  it 'does not accept a value with whitespace' do
    yum_cron_hourly_config[:value] = 'b ar'
    expect(yum_cron_hourly_config[:value]).to eql('b ar')
  end

  it 'accepts valid ensure values' do
    yum_cron_hourly_config[:ensure] = :present
    expect(yum_cron_hourly_config[:ensure]).to be(:present)
    yum_cron_hourly_config[:ensure] = :absent
    expect(yum_cron_hourly_config[:ensure]).to be(:absent)
  end

  it 'does not accept invalid ensure values' do
    expect {
      yum_cron_hourly_config[:ensure] = :latest
    }.to raise_error(Puppet::Error, %r{Invalid value})
  end

  describe 'autorequire resources' do
    it 'autorequires File[/etc/yum/yum-cron-hourly.conf]' do
      conf = Puppet::Type.type(:file).new(name: '/etc/yum/yum-cron-hourly.conf')
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource yum_cron_hourly_config
      catalog.add_resource conf
      rel = yum_cron_hourly_config.autorequire[0]
      expect(rel.source.ref).to eql(conf.ref)
      expect(rel.target.ref).to eql(yum_cron_hourly_config.ref)
    end

    it 'autorequires Package[yum-cron]' do
      conf = Puppet::Type.type(:package).new(name: 'yum-cron')
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource yum_cron_hourly_config
      catalog.add_resource conf
      rel = yum_cron_hourly_config.autorequire[0]
      expect(rel.source.ref).to eql(conf.ref)
      expect(rel.target.ref).to eql(yum_cron_hourly_config.ref)
    end
  end
end
