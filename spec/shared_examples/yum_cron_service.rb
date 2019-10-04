shared_examples 'yum_cron::service' do |_facts|
  let(:service_name) do
    case facts[:os]['release']['major'].to_i
    when 8
      'dnf-automatic.timer'
    else
      'yum-cron'
    end
  end

  it do
    is_expected.to contain_service('yum-cron').with(ensure: 'running',
                                                    enable: 'true',
                                                    name: service_name,
                                                    hasstatus: 'true',
                                                    hasrestart: 'true')
  end

  context 'ensure => absent' do
    let(:params) { { ensure: 'absent' } }

    it { is_expected.to contain_service('yum-cron').with_ensure('stopped') }
    it { is_expected.to contain_service('yum-cron').with_enable('false') }
  end
end
