shared_examples 'yum_cron::install' do |facts|
  it do
    is_expected.to contain_package('yum-cron').with(ensure: 'present',
                                                    name: 'yum-cron')
  end

  context 'ensure => absent' do
    let(:params) { { ensure: 'absent' } }

    it { is_expected.to contain_package('yum-cron').with_ensure('absent') }
  end

  it { is_expected.not_to contain_package('yum-autoupdate') }

  if facts[:operatingsystem] =~ %r{Scientific}
    context "yum_autoupdate_ensure => 'absent'" do
      let(:params) { { yum_autoupdate_ensure: 'absent' } }

      it { is_expected.to contain_package('yum-autoupdate').with_ensure('absent') }
    end

    context "yum_autoupdate_ensure => 'undef'" do
      let(:params) { { yum_autoupdate_ensure: 'undef' } }

      it { is_expected.not_to contain_package('yum-autoupdate') }
    end

    context "yum_autoupdate_ensure => 'UNSET'" do
      let(:params) { { yum_autoupdate_ensure: 'UNSET' } }

      it { is_expected.not_to contain_package('yum-autoupdate') }
    end
  end
end
