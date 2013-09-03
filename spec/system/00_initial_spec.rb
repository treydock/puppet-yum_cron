require 'spec_helper_system'

describe 'installation tasks' do
  context puppet_agent do
    its(:stderr) { should be_empty }
    its(:exit_code) { should_not == 1 }
  end
end
