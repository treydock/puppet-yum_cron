require 'spec_helper_acceptance'

describe 'yum_cron class:' do
  context 'with default parameters' do
    it 'runs successfully' do
      pp = "class { 'yum_cron': }"

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package(defaults(fact('os.release.major').to_i, 'package')) do
      it { is_expected.to be_installed }
    end

    describe service(defaults(fact('os.release.major').to_i, 'service')) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    if fact('operatingsystemmajrelease') <= '6'
      describe file('/etc/yum/yum-cron.conf') do
        it { is_expected.not_to be_file }
      end
      describe file('/etc/sysconfig/yum-cron') do
        it { is_expected.to be_file }
        it { is_expected.to be_owned_by 'root' }
        it { is_expected.to be_grouped_into 'root' }
        it { is_expected.to be_mode 644 }
        its(:content) { is_expected.to match %r{^CHECK_ONLY=yes$} }
        its(:content) { is_expected.to match %r{^DOWNLOAD_ONLY=yes$} }
        if fact('operatingsystemmajrelease') >= '6'
          its(:content) { is_expected.to match %r{^DEBUG_LEVEL=0$} }
          its(:content) { is_expected.to match %r{^RANDOMWAIT="60"$} }
          its(:content) { is_expected.to match %r{^MAILTO=root(?:\s+)?$} } # For some reason a trailing space exists
          its(:content) { is_expected.to match %r{^SYSTEMNAME=#{fact('fqdn')}$} }
          its(:content) { is_expected.to match %r{^DAYS_OF_WEEK=0123456$} }
          its(:content) { is_expected.to match %r{^CLEANDAY="0"$} }
        end
      end
    else
      describe file('/etc/sysconfig/yum-cron') do
        it { is_expected.not_to be_file }
      end
      describe file(defaults(fact('os.release.major').to_i, 'config')) do
        it { is_expected.to be_file }
        it { is_expected.to be_owned_by 'root' }
        it { is_expected.to be_grouped_into 'root' }
        it { is_expected.to be_mode 644 }
        its(:content) { is_expected.to match %r{^update_cmd = default$} }
        its(:content) { is_expected.to match %r{^update_messages = yes$} }
        its(:content) { is_expected.to match %r{^download_updates = yes$} }
        its(:content) { is_expected.to match %r{^apply_updates = no$} }
        its(:content) { is_expected.to match %r{^random_sleep = 360$} }
        its(:content) { is_expected.to match %r{^system_name = #{fact('fqdn')}$} }
        its(:content) { is_expected.to match %r{^email_to = root$} }
        its(:content) { is_expected.to match %r{^email_host = localhost$} }
        its(:content) { is_expected.to match %r{^debuglevel = -2$} }
      end
    end

    if fact('operatingsystem') =~ %r{Scientific}
      describe package('yum-autoupdate') do
        it { is_expected.to be_installed }
      end

      describe file('/etc/sysconfig/yum-autoupdate') do
        its(:content) { is_expected.to match %r{^ENABLED=false$} }
      end
    end
  end

  context 'with automatic updates enabled' do
    it 'runs successfully' do
      pp = "class { 'yum_cron': apply_updates => true }"

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    if fact('operatingsystemmajrelease') <= '6'
      describe file('/etc/sysconfig/yum-cron') do
        its(:content) { is_expected.to match %r{^CHECK_ONLY=no$} }
        its(:content) { is_expected.to match %r{^DOWNLOAD_ONLY=no$} }
      end
    else
      describe file(defaults(fact('os.release.major').to_i, 'config')) do
        its(:content) { is_expected.to match %r{^download_updates = yes$} }
        its(:content) { is_expected.to match %r{^apply_updates = yes$} }
      end
    end
  end

  context 'when enable => false' do
    it 'runs successfully' do
      pp = "class { 'yum_cron': enable => false }"

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package(defaults(fact('os.release.major').to_i, 'package')) do
      it { is_expected.to be_installed }
    end

    describe service(defaults(fact('os.release.major').to_i, 'service')) do
      it { is_expected.not_to be_enabled }
      it { is_expected.not_to be_running }
    end
  end

  context 'when ensure => absent' do
    it 'runs successfully' do
      pp = "class { 'yum_cron': ensure => 'absent' }"

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package(defaults(fact('os.release.major').to_i, 'package')) do
      it { is_expected.not_to be_installed }
    end

    describe service(defaults(fact('os.release.major').to_i, 'service')) do
      it { is_expected.not_to be_enabled }
      it { is_expected.not_to be_running }
    end
  end

  if fact('operatingsystem') =~ %r{Scientific}
    context "with yum_autoupdate_ensure => 'absent'" do
      it 'removes yum-autoupdate' do
        pp = "class { 'yum_cron': yum_autoupdate_ensure => 'absent' }"

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      describe package('yum-autoupdate') do
        it { is_expected.not_to be_installed }
      end
    end
  end
end
