require 'spec_helper'

describe 'yum_cron' do
  include_context :default_facts

  let :facts do
    default_facts
  end

  it { should create_class('yum_cron') }
  it { should contain_class('yum_cron::params') }

  it do
    should contain_package('yum-cron').with({
      'ensure'    => 'present',
      'name'      => 'yum-cron',
      'before'    => 'File[/etc/sysconfig/yum-cron]',
    })
  end

  it do
    should contain_service('yum-cron').with({
      'ensure'      => 'running',
      'enable'      => 'true',
      'name'        => 'yum-cron',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'subscribe'   => 'File[/etc/sysconfig/yum-cron]',
    })
  end

  it do
    should contain_file('/etc/sysconfig/yum-cron').with({
      'ensure'  => 'present',
      'path'    => '/etc/sysconfig/yum-cron',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
    })
  end

  it 'should have valid config' do
    verify_contents(subject, '/etc/sysconfig/yum-cron', [
      'YUM_PARAMETER=',
      'CHECK_ONLY=yes',
      'CHECK_FIRST=no',
      'DOWNLOAD_ONLY=no',
      'ERROR_LEVEL=0',
      'DEBUG_LEVEL=1',
      'RANDOMWAIT=60',
      'MAILTO=root',
      'SYSTEMNAME=',
      'DAYS_OF_WEEK=0123456',
      'CLEANDAY=0',
      'SERVICE_WAITS=yes',
      'SERVICE_WAIT_TIME=300',
    ])
  end

  it { should_not contain_augeas('disable yum-autoupdate') }

  context 'with service_ensure => "undef"' do
    let(:params) {{ :service_ensure => "undef" }}
    it { should contain_service('yum-cron').with_ensure(nil) }
  end

  context 'with service_enable => "undef"' do
    let(:params) {{ :service_enable => "undef" }}
    it { should contain_service('yum-cron').with_enable(nil) }
  end

  # Test boolean validation
  [
    'disable_yum_autoupdate',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param => 'foo' }}
      it { expect { should create_class('yum_cron') }.to raise_error(Puppet::Error, /is not a boolean/) }
    end
  end

  # Test yes/no parameter validation
  [
    'check_only',
    'check_first',
    'download_only',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param => 'foo' }}
      it { expect { should create_class('yum_cron') }.to raise_error(Puppet::Error, /does not match "\^yes\|no\$"/) }
    end
  end

  [
    {
      'check_only' => 'no',
      'check_first' => 'yes',
      'download_only' => 'yes',
      'error_level' => 2,
      'debug_level' => 0,
      'randomwait' => 30,
      'mailto' => 'foo@bar',
      'systemname' => 'foo.bar',
      'days_of_week' => '06',
      'cleanday' => 6,
      'service_waits' => 'no',
      'service_wait_time' => 200,
    }
  ].each do |passed_params|
    context "with non-default configuration values" do
      let :params do
        passed_params
      end
      
      passed_params.each_pair do |key,value|
        it "should set #{key.upcase}=#{value}" do
          verify_contents(subject, '/etc/sysconfig/yum-cron', ["#{key.upcase}=#{value}"])
        end
      end
    end
  end

  describe 'operatingsystem => Scientific' do
    let(:facts) { default_facts.merge({ :operatingsystem => "Scientific" })}

    it { should contain_augeas('disable yum-autoupdate') }

    describe_augeas 'disable yum-autoupdate', :lens => 'Shellvars', :target => 'etc/sysconfig/yum-autoupdate' do
      it 'should change ENABLED to false' do
        should execute.with_change
        aug_get("ENABLED").should == "false"
        should execute.idempotently
      end
    end
    
    context 'disable_yum_autoupdate => false' do
      let(:params) {{ :disable_yum_autoupdate => false }}
      it { should_not contain_augeas('disable yum-autoupdate') }
    end
  end
end
