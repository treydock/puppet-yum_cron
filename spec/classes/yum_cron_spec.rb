require 'spec_helper'

describe 'yum_cron' do
  let :default_facts do
    {
      :kernel                     => 'Linux',
      :osfamily                   => 'RedHat',
      :operatingsystem            => 'CentOS',
      :operatingsystemmajrelease  => '6',
      :architecture               => 'x86_64',
      :fqdn                       => 'foo.example.com',
    }
  end

  let(:facts) { default_facts }
  let(:params) {{}}

  it { should create_class('yum_cron') }
  it { should contain_class('yum_cron::params') }

  it do
    should contain_package('yum-cron').with({
      :ensure     => 'present',
      :name       => 'yum-cron',
      :before     => 'File[yum-cron-config]',
    })
  end

  it do
    should contain_service('yum-cron').with({
      :ensure       => 'running',
      :enable       => 'true',
      :name         => 'yum-cron',
      :hasstatus    => 'true',
      :hasrestart   => 'true',
      :subscribe    => 'File[yum-cron-config]',
    })
  end

  it do
    should contain_file('yum-cron-config').with({
      :ensure   => 'present',
      :path     => '/etc/sysconfig/yum-cron',
      :owner    => 'root',
      :group    => 'root',
      :mode     => '0644',
      :before   => 'Service[yum-cron]',
    })
  end

  it 'should have valid config' do
    content = catalogue.resource('file', 'yum-cron-config').send(:parameters)[:content]
    content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
      'YUM_PARAMETER=',
      'CHECK_ONLY=yes',
      'CHECK_FIRST=no',
      'DOWNLOAD_ONLY=no',
      'ERROR_LEVEL=0',
      'DEBUG_LEVEL=0',
      'RANDOMWAIT=60',
      'MAILTO=root',
      "SYSTEMNAME=#{facts[:fqdn]}",
      'DAYS_OF_WEEK=0123456',
      'CLEANDAY=0',
      'SERVICE_WAITS=yes',
      'SERVICE_WAIT_TIME=300',
    ]
  end

  it { should_not contain_package('yum-autoupdate') }
  it { should_not contain_file_line('disable yum-autoupdate') }

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
          verify_contents(catalogue, 'yum-cron-config', ["#{key.upcase}=#{value}"])
        end
      end
    end
  end

  describe 'operatingsystem => Scientific' do
    let(:facts) { default_facts.merge({ :operatingsystem => "Scientific" })}

    it { should_not contain_package('yum-autoupdate') }

    it do
      should contain_file_line('disable yum-autoupdate').with({
        :path  => '/etc/sysconfig/yum-autoupdate',
        :line  => 'ENABLED=false',
        :match => '^ENABLED=.*',
      })
    end

    context "yum_autoupdate_ensure => 'absent'" do
      let(:params) {{ :yum_autoupdate_ensure => 'absent' }}
      it { should contain_package('yum-autoupdate').with_ensure('absent') }
      it { should_not contain_file_line('disable yum-autoupdate') }
    end

    context "yum_autoupdate_ensure => 'undef'" do
      let(:params) {{ :yum_autoupdate_ensure => 'undef' }}
      it { should_not contain_package('yum-autoupdate') }
      it { should_not contain_file_line('disable yum-autoupdate') }
    end

    context "yum_autoupdate_ensure => 'UNSET'" do
      let(:params) {{ :yum_autoupdate_ensure => 'UNSET' }}
      it { should_not contain_package('yum-autoupdate') }
      it { should_not contain_file_line('disable yum-autoupdate') }
    end

    context "yum_autoupdate_ensure => 'foo'" do
      let(:params) {{ :yum_autoupdate_ensure => 'foo' }}
      it { expect { should create_class('yum_cron') }.to raise_error(Puppet::Error, /does not match \["\^undef", "\^UNSET", "\^absent", "\^disabled"\]/) }
    end
  end

  describe 'operatingsystemmajrelease => "5"' do
    let(:facts) { default_facts.merge({ :operatingsystemmajrelease => "5" })}

    it 'should only set CHECK_ONLY and DOWNLOAD_ONLY' do
      content = catalogue.resource('file', 'yum-cron-config').send(:parameters)[:content]
      content.split("\n").reject { |c| c =~ /(^#|^$)/ }.should == [
        'CHECK_ONLY=yes',
        'DOWNLOAD_ONLY=no',
      ]
    end

    context "with check_first => 'foo'" do
      let(:params) {{ :check_first => 'foo' }}
      it { expect { should create_class('yum_cron') }.not_to raise_error }
    end
  end

  describe 'operatingsystemmajrelease => "7"' do
    let(:facts) { default_facts.merge({ :operatingsystemmajrelease => "7" })}

    it do
      should contain_file('yum-cron-config').with_path('/etc/yum/yum-cron.conf')
    end

    it 'should only set apply_updates, system_name and email_to' do
      verify_contents(catalogue, 'yum-cron-config', [
        'apply_updates = no',
        'system_name = foo.example.com',
        'email_to = root',
      ])
    end

    context "when check_only => 'no'" do
      let(:params) {{ :check_only => 'no' }}
      it 'should set apply_updates = yes' do
        verify_contents(catalogue, 'yum-cron-config', [
          'apply_updates = yes',
        ])
      end
    end

    context "with download_only => 'foo'" do
      let(:params) {{ :download_only => 'foo' }}
      it { expect { should create_class('yum_cron') }.not_to raise_error }
    end

    context "with check_first => 'foo'" do
      let(:params) {{ :check_first => 'foo' }}
      it { expect { should create_class('yum_cron') }.not_to raise_error }
    end
  end
end
