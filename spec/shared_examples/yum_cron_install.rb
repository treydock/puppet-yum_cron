shared_examples 'yum_cron::install' do |facts|
  it do
    should contain_package('yum-cron').with({
      :ensure     => 'present',
      :name       => 'yum-cron',
    })
  end

  context 'ensure => absent' do
    let(:params) {{ :ensure => 'absent' }}
    it { should contain_package('yum-cron').with_ensure('absent') }
  end

  if facts[:operatingsystem] =~ /Scientific/
    it { should_not contain_package('yum-autoupdate') }

    context "yum_autoupdate_ensure => 'absent'" do
      let(:params) {{ :yum_autoupdate_ensure => 'absent' }}
      it { should contain_package('yum-autoupdate').with_ensure('absent') }
    end

    context "yum_autoupdate_ensure => 'undef'" do
      let(:params) {{ :yum_autoupdate_ensure => 'undef' }}
      it { should_not contain_package('yum-autoupdate') }
    end

    context "yum_autoupdate_ensure => 'UNSET'" do
      let(:params) {{ :yum_autoupdate_ensure => 'UNSET' }}
      it { should_not contain_package('yum-autoupdate') }
    end
  else
    it { should_not contain_package('yum-autoupdate') }
  end
end
