require 'spec_helper_system'

describe 'yum_cron class:' do
  context 'should run successfully' do
    pp =<<-EOS
class { 'yum_cron': }
    EOS
  
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
      describe file('/etc/sysconfig/yum-autoupdate') do
        it { should contain 'ENABLED=false' }
      end
    end
  end
end
