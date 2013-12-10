require 'spec_helper'

describe 'yum_cron' do
  include_context :default_facts

  let(:facts) { default_facts }
  let(:params) {{}}

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
      'before'  => 'Service[yum-cron]',
    })
  end

  it 'should have valid config' do
    verify_contents(subject, '/etc/sysconfig/yum-cron', [
      'YUM_PARAMETER=',
      'CHECK_ONLY=yes',
      'CHECK_FIRST=no',
      'DOWNLOAD_ONLY=no',
      'ERROR_LEVEL=0',
      'DEBUG_LEVEL=0',
      'RANDOMWAIT=60',
      'MAILTO=root',
      "SYSTEMNAME=#{node}",
      'DAYS_OF_WEEK=0123456',
      'CLEANDAY=0',
      'SERVICE_WAITS=yes',
      'SERVICE_WAIT_TIME=300',
    ])
  end

  it { should_not contain_package('yum-autoupdate') }
  it { should_not contain_shellvar('disable yum-autoupdate') }

  context 'with service_autorestart => false' do
    let(:params) {{ :service_autorestart => false }}
    it { should contain_service('yum-cron').with_subscribe(nil) }
  end

  # Test service ensure and enable 'magic' values
  [
    'undef',
    'UNSET',
  ].each do |v|
    context "with service_ensure => '#{v}'" do
      let(:params) {{ :service_ensure => v }}
      it { should contain_service('yum-cron').with_ensure(nil) }
    end

    context "with service_enable => '#{v}'" do
      let(:params) {{ :service_enable => v }}
      it { should contain_service('yum-cron').with_enable(nil) }
    end
  end

  # Test boolean validation
  [
    'service_autorestart',
  ].each do |param|
    context "with #{param} => 'foo'" do
      let(:params) {{ param.to_sym => 'foo' }}
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
      let(:params) {{ param.to_sym => 'foo' }}
      it { expect { should create_class('yum_cron') }.to raise_error(Puppet::Error, /does not match \["\^yes", "\^no"\]/) }
    end
  end

  context "with non-default configuration values" do
    [
      {
        'check_only' => 'no',
        'check_first' => 'yes',
        'download_only' => 'yes',
        'error_level' => 1,
        'debug_level' => 1,
        'randomwait' => 30,
        'mailto' => 'foo@bar',
        'systemname' => 'foo.bar',
        'days_of_week' => '06',
        'cleanday' => 6,
        'service_waits' => 'no',
        'service_wait_time' => 200,
      }
    ].each do |passed_params|
      let(:params) { passed_params }
    
      passed_params.each_pair do |key,value|
        it "should set #{key.upcase}=#{value}" do
          verify_contents(subject, '/etc/sysconfig/yum-cron', ["#{key.upcase}=#{value}"])
        end
      end
    end
  end

  describe 'operatingsystem => Scientific' do
    let(:facts) { default_facts.merge({ :operatingsystem => "Scientific" })}

    it { should_not contain_package('yum-autoupdate') }

    it do
      should contain_shellvar('disable yum-autoupdate').with({
        'variable'  => 'ENABLED',
        'value'     => 'false',
        'target'    => '/etc/sysconfig/yum-autoupdate',
      })
    end

    context "yum_autoupdate_ensure => 'absent'" do
      let(:params) {{ :yum_autoupdate_ensure => 'absent' }}
      it { should contain_package('yum-autoupdate').with_ensure('absent') }
      it { should_not contain_shellvar('disable yum-autoupdate') }
    end

    context "yum_autoupdate_ensure => 'undef'" do
      let(:params) {{ :yum_autoupdate_ensure => 'undef' }}
      it { should_not contain_package('yum-autoupdate') }
      it { should_not contain_shellvar('disable yum-autoupdate') }
    end

    context "yum_autoupdate_ensure => 'UNSET'" do
      let(:params) {{ :yum_autoupdate_ensure => 'UNSET' }}
      it { should_not contain_package('yum-autoupdate') }
      it { should_not contain_shellvar('disable yum-autoupdate') }
    end

    context "yum_autoupdate_ensure => 'foo'" do
      let(:params) {{ :yum_autoupdate_ensure => 'foo' }}
      it { expect { should create_class('yum_cron') }.to raise_error(Puppet::Error, /does not match \["\^undef", "\^UNSET", "\^absent", "\^disabled"\]/) }
    end
  end
end
