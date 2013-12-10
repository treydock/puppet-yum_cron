require 'spec_helper_system'

describe 'yum_cron class:' do
  context 'with default parameters' do
    it 'should run successfully' do
      pp = "class { 'yum_cron': }"

      puppet_apply(pp) do |r|
       r.exit_code.should_not == 1
       r.refresh
       r.exit_code.should be_zero
      end
    end

    describe package('yum-cron') do
      it { should be_installed }
    end

    describe service('yum-cron') do
      it { should be_enabled }
      it { should be_running }
    end
  
    describe file('/etc/sysconfig/yum-cron') do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 644 }
      its(:content) { should match /^CHECK_ONLY=yes$/ }
      its(:content) { should match /^MAILTO=root$/ }
    end

    if node.facts['operatingsystem'] =~ /Scientific/
      describe package('yum-autoupdate') do
        it { should be_installed }
      end

      describe file('/etc/sysconfig/yum-autoupdate') do
        its(:content) { should match /^ENABLED="false"$/ }
      end
    end
  end

  if node.facts['operatingsystem'] =~ /Scientific/
    context "with yum_autoupdate_ensure => 'absent'" do
      it 'should remove yum-autoupdate' do
        pp = "class { 'yum_cron': yum_autoupdate_ensure => 'absent' }"

        puppet_apply(pp) do |r|
         r.exit_code.should_not == 1
         r.refresh
         r.exit_code.should be_zero
        end
      end
        
      describe package('yum-autoupdate') do
        it { should_not be_installed }
      end
    end
  end
end
