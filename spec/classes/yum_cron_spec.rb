require 'spec_helper'

describe 'yum_cron' do
  include_context :default_facts

  let :facts do
    default_facts
  end

  it { should create_class('yum_cron') }
  it { should contain_class('yum_cron::params') }

  it do
    should contain_package('yum_cron').with({
      'ensure'    => 'present',
      'name'      => 'yum_cron',
      'before'    => 'File[/etc/yum_cron]',
    })
  end

  it do
    should contain_service('yum_cron').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'name'        => 'yum_cron',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'subscribe'   => 'File[/etc/yum_cron]',
    })
  end

  it do
    should contain_file('/etc/yum_cron').with({
      'ensure'  => 'present',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
    })
  end
end
