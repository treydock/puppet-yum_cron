require 'spec_helper_acceptance'

describe 'yum_cron class:' do
  context 'with default parameters' do
    it 'should run successfully' do
      pp = "class { 'yum_cron': }"

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe package('yum-cron') do
      it { should be_installed }
    end

    describe service('yum-cron') do
      it { should be_enabled }
      it { should be_running }
    end

    if fact('operatingsystemmajrelease') <= '6'
      describe file('/etc/yum/yum-cron.conf') do
        it { should_not be_file }
      end
      describe file('/etc/sysconfig/yum-cron') do
        it { should be_file }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_mode 644 }
        its(:content) { should match /^CHECK_ONLY=yes$/ }
        its(:content) { should match /^DOWNLOAD_ONLY=yes$/ }
        if fact('operatingsystemmajrelease') >= '6'
          its(:content) { should match /^DEBUG_LEVEL=0$/ }
          its(:content) { should match /^RANDOMWAIT="60"$/ }
          its(:content) { should match /^MAILTO=root(?:\s+)?$/ } # For some reason a trailing space exists
          its(:content) { should match /^SYSTEMNAME=#{fact('fqdn')}$/ }
          its(:content) { should match /^DAYS_OF_WEEK=0123456$/ }
          its(:content) { should match /^CLEANDAY="0"$/ }
        end
      end
    else
      describe file('/etc/sysconfig/yum-cron') do
        it { should_not be_file }
      end
      describe file('/etc/yum/yum-cron.conf') do
        it { should be_file }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_mode 644 }
        its(:content) { should match /^update_cmd = default$/ }
        its(:content) { should match /^update_messages = yes$/ }
        its(:content) { should match /^download_updates = yes$/ }
        its(:content) { should match /^apply_updates = no$/ }
        its(:content) { should match /^random_sleep = 360$/ }
        its(:content) { should match /^system_name = #{fact('fqdn')}$/ }
        its(:content) { should match /^email_to = root$/ }
        its(:content) { should match /^email_host = localhost$/ }
        its(:content) { should match /^debuglevel = -2$/ }
      end
    end

    if fact('operatingsystem') =~ /Scientific/
      describe package('yum-autoupdate') do
        it { should be_installed }
      end

      describe file('/etc/sysconfig/yum-autoupdate') do
        its(:content) { should match /^ENABLED=false$/ }
      end
    end
  end

  context 'with automatic updates enabled' do
    it 'should run successfully' do
      pp = "class { 'yum_cron': apply_updates => true }"

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    if fact('operatingsystemmajrelease') <= '6'
      describe file('/etc/sysconfig/yum-cron') do
        its(:content) { should match /^CHECK_ONLY=no$/ }
        its(:content) { should match /^DOWNLOAD_ONLY=no$/ }
      end
    else
      describe file('/etc/yum/yum-cron.conf') do
        its(:content) { should match /^download_updates = yes$/ }
        its(:content) { should match /^apply_updates = yes$/ }
      end
    end
  end

  context 'when enable => false' do
    it 'should run successfully' do
      pp = "class { 'yum_cron': enable => false }"

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe package('yum-cron') do
      it { should be_installed }
    end

    describe service('yum-cron') do
      it { should_not be_enabled }
      it { should_not be_running }
    end
  end

  context 'when ensure => absent' do
    it 'should run successfully' do
      pp = "class { 'yum_cron': ensure => 'absent' }"

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe package('yum-cron') do
      it { should_not be_installed }
    end

    describe service('yum-cron') do
      it { should_not be_enabled }
      it { should_not be_running }
    end
  end

  if fact('operatingsystem') =~ /Scientific/
    context "with yum_autoupdate_ensure => 'absent'" do
      it 'should remove yum-autoupdate' do
        pp = "class { 'yum_cron': yum_autoupdate_ensure => 'absent' }"

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true)
      end

      describe package('yum-autoupdate') do
        it { should_not be_installed }
      end
    end
  end
end
