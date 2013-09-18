require 'spec_helper_system'

describe 'yum_cron class:' do
  context 'should run successfully' do
    pp = "class { 'yum_cron': }"

    context puppet_apply(pp) do
       its(:stderr) { should be_empty }
       its(:exit_code) { should_not == 1 }
       its(:refresh) { should be_nil }
       its(:stderr) { should be_empty }
       its(:exit_code) { should be_zero }
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
    it { should contain 'CHECK_ONLY=yes' }
    it { should contain 'MAILTO=root' }
  end

  if node.facts['operatingsystem'] =~ /Scientific/
    context 'should disable yum-autoupdate' do
      pp = "class { 'yum_cron': }"

      context puppet_apply(pp) do
         its(:stderr) { should be_empty }
         its(:exit_code) { should_not == 1 }
         its(:refresh) { should be_nil }
         its(:stderr) { should be_empty }
         its(:exit_code) { should be_zero }
      end

      describe file('/etc/sysconfig/yum-autoupdate') do
        it { should contain 'ENABLED="false"' }
      end
    end

    context 'should remove yum-autoupdate' do
      pp = "class { 'yum_cron': remove_yum_autoupdate => true }"
  
      context puppet_apply(pp) do
         its(:stderr) { should be_empty }
         its(:exit_code) { should_not == 1 }
         its(:refresh) { should be_nil }
         its(:stderr) { should be_empty }
         its(:exit_code) { should be_zero }
      end

      describe package('yum-autoupdate') do
        it { should_not be_installed }
      end
    end
  end
end
