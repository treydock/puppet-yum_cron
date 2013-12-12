require 'puppetlabs_spec_helper/module_spec_helper'

$:.unshift File.join(File.dirname(__FILE__),  'fixtures', 'modules', 'stdlib', 'lib')
$:.unshift File.join(File.dirname(__FILE__),  'fixtures', 'modules', 'augeasproviders', 'lib')

shared_context :default_facts do
  let(:node) { 'foo.example.com' }

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
