require 'puppet'
require 'puppet/type/yum_cron_config'

describe 'Puppet::Type.type(:yum_cron_config)' do
  before :each do
    @yum_cron_config = Puppet::Type.type(:yum_cron_config).new(:name => 'vars/foo', :value => 'bar')
  end

  it 'should require a name' do
    expect {
      Puppet::Type.type(:yum_cron_config).new({})
    }.to raise_error(Puppet::Error, 'Title or name must be provided')
  end

  it 'should not expect a name with whitespace' do
    expect {
      Puppet::Type.type(:yum_cron_config).new(:name => 'f oo')
    }.to raise_error(Puppet::Error, /Invalid yum_cron_config/)
  end

  it 'should fail when there is no section' do
    expect {
      Puppet::Type.type(:yum_cron_config).new(:name => 'foo')
    }.to raise_error(Puppet::Error, /Invalid yum_cron_config/)
  end

  it 'should not require a value when ensure is absent' do
    Puppet::Type.type(:yum_cron_config).new(:name => 'vars/foo', :ensure => :absent)
  end

  it 'should require a value when ensure is present' do
    expect {
      Puppet::Type.type(:yum_cron_config).new(:name => 'vars/foo', :ensure => :present)
    }.to raise_error(Puppet::Error, /Property value must be set/)
  end

  it 'should accept a valid value' do
    @yum_cron_config[:value] = 'bar'
    expect(@yum_cron_config[:value]).to eql('bar')
  end

  it 'should not accept a value with whitespace' do
    @yum_cron_config[:value] = 'b ar'
    expect(@yum_cron_config[:value]).to eql('b ar')
  end

  it 'should accept valid ensure values' do
    @yum_cron_config[:ensure] = :present
    expect(@yum_cron_config[:ensure]).to eql(:present)
    @yum_cron_config[:ensure] = :absent
    expect(@yum_cron_config[:ensure]).to eql(:absent)
  end

  it 'should not accept invalid ensure values' do
    expect {
      @yum_cron_config[:ensure] = :latest
    }.to raise_error(Puppet::Error, /Invalid value/)
  end

  describe 'autorequire resources' do
    it 'should autorequire File[/etc/yum/yum-cron.conf]' do
      conf = Puppet::Type.type(:file).new(:name => '/etc/yum/yum-cron.conf')
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource @yum_cron_config
      catalog.add_resource conf
      rel = @yum_cron_config.autorequire[0]
      expect(rel.source.ref).to eql(conf.ref)
      expect(rel.target.ref).to eql(@yum_cron_config.ref)
    end

    it 'should autorequire Package[yum-cron]' do
      conf = Puppet::Type.type(:package).new(:name => 'yum-cron')
      catalog = Puppet::Resource::Catalog.new
      catalog.add_resource @yum_cron_config
      catalog.add_resource conf
      rel = @yum_cron_config.autorequire[0]
      expect(rel.source.ref).to eql(conf.ref)
      expect(rel.target.ref).to eql(@yum_cron_config.ref)
    end
  end
end
