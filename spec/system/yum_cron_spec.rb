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
end
