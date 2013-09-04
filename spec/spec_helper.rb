require 'rspec-puppet-augeas'
require 'puppetlabs_spec_helper/module_spec_helper'

shared_context :default_facts do
  let :default_facts do
    {
      :kernel                 => 'Linux',
      :osfamily               => 'RedHat',
      :operatingsystem        => 'CentOS',
      :operatingsystemrelease => '6.4',
      :architecture           => 'x86_64',
    }
  end
end

fixture_path = File.expand_path(File.join(Dir.pwd, 'spec/fixtures'))

RSpec.configure do |c|
  c.augeas_fixtures = File.join(fixture_path, 'augeas')
end
