shared_examples 'yum_cron::service' do |facts|
  it do
    should contain_service('yum-cron').with({
      :ensure       => 'running',
      :enable       => 'true',
      :name         => 'yum-cron',
      :hasstatus    => 'true',
      :hasrestart   => 'true',
    })
  end

  context 'ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_service('yum-cron').with_ensure('stopped') }
    it { should contain_service('yum-cron').with_enable('false') }
  end
end
