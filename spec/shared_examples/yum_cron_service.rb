# frozen_string_literal: true

shared_examples 'yum_cron::service' do |_facts|
  let(:service_name) do
    case facts[:os]['release']['major'].to_i
    when 2, 7
      'yum-cron'
    else
      'dnf-automatic.timer'
    end
  end

  it do
    is_expected.to contain_service('yum-cron').with(ensure: 'running',
                                                    enable: 'true',
                                                    name: service_name,
                                                    hasstatus: 'true',
                                                    hasrestart: 'true',)
  end

  context 'when ensure => absent' do
    let(:params) { { ensure: 'absent' } }

    it { is_expected.to contain_service('yum-cron').with_ensure('stopped') }
    it { is_expected.to contain_service('yum-cron').with_enable('false') }
  end
end
