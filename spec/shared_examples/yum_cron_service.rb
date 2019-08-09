shared_examples 'yum_cron::service' do |_facts|
  it do
    is_expected.to contain_service('yum-cron').with(ensure: 'running',
                                                    enable: 'true',
                                                    name: 'yum-cron',
                                                    hasstatus: 'true',
                                                    hasrestart: 'true')
  end

  context 'ensure => absent' do
    let(:params) { { ensure: 'absent' } }

    it { is_expected.to contain_service('yum-cron').with_ensure('stopped') }
    it { is_expected.to contain_service('yum-cron').with_enable('false') }
  end
end
