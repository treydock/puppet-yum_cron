shared_examples 'yum_cron::config' do |facts|
  unless defined?(EL7_CONFIGS)
    EL7_CONFIGS = [
      { name: 'commands/update_cmd', value: 'default' },
      { name: 'commands/update_messages', value: 'yes' },
      { name: 'commands/download_updates', value: 'yes' },
      { name: 'commands/apply_updates', value: 'no' },
      { name: 'commands/random_sleep', value: '360' },
      { name: 'emitters/system_name', value: facts[:fqdn] },
      { name: 'email/email_to', value: 'root' },
      { name: 'email/email_host', value: 'localhost' },
      { name: 'base/debuglevel', value: '-2' },
    ].freeze
  end

  unless defined?(EL6_CONFIGS)
    EL6_CONFIGS = [
      { name: 'CHECK_ONLY', value: 'yes' },
      { name: 'DOWNLOAD_ONLY', value: 'yes' },
      { name: 'DEBUG_LEVEL', value: '0' },
      { name: 'RANDOMWAIT', value: '60' },
      { name: 'MAILTO', value: 'root' },
      { name: 'SYSTEMNAME', value: facts[:fqdn] },
      { name: 'DAYS_OF_WEEK', value: '0123456' },
      { name: 'CLEANDAY', value: '0' },
    ].freeze
  end

  unless defined?(EL5_CONFIGS)
    EL5_CONFIGS = [
      { name: 'CHECK_ONLY', value: 'yes' },
      { name: 'DOWNLOAD_ONLY', value: 'yes' },
    ].freeze
  end

  case facts[:operatingsystemmajrelease]
  when '7'
    EL7_CONFIGS.each do |config|
      it "should set #{config[:name]} to #{config[:value]}" do
        is_expected.to contain_yum_cron_config(config[:name]).with(value: config[:value],
                                                                   notify: 'Service[yum-cron]')
      end
    end

    it { is_expected.to have_yum_cron_config_resource_count(EL7_CONFIGS.size) }
    it { is_expected.to have_shellvar_resource_count(0) }

    context 'when enable => false' do
      let(:params) { { enable: false } }

      EL7_CONFIGS.each do |config|
        it 'does not notify Service[yum-cron]' do
          is_expected.to contain_yum_cron_config(config[:name]).without_notify
        end
      end
    end

    context 'extra_configs defined' do
      let(:params) do
        {
          extra_configs: {
            'email/email_from' => { 'value' => 'foo@bar.com' },
          },
        }
      end

      it do
        is_expected.to contain_yum_cron_config('email/email_from').with(value: 'foo@bar.com',
                                                                        notify: 'Service[yum-cron]')
      end
    end
  when '6'
    EL6_CONFIGS.each do |config|
      it "should set #{config[:name]} to #{config[:value]}" do
        is_expected.to contain_shellvar("yum_cron #{config[:name]}").with(ensure: 'present',
                                                                          target: '/etc/sysconfig/yum-cron',
                                                                          notify: 'Service[yum-cron]',
                                                                          variable: config[:name],
                                                                          value: config[:value])
      end
    end

    it { is_expected.to have_yum_cron_config_resource_count(0) }
    it { is_expected.to have_shellvar_resource_count(EL6_CONFIGS.size) }

    context 'when enable => false' do
      let(:params) { { enable: false } }

      EL6_CONFIGS.each do |config|
        it 'does not notify Service[yum-cron]' do
          is_expected.to contain_shellvar("yum_cron #{config[:name]}").without_notify
        end
      end
    end

    context 'extra_configs defined' do
      let(:params) do
        {
          extra_configs: {
            'yum_cron ERROR_LEVEL' => { 'variable' => 'ERROR_LEVEL', 'value' => '1' },
          },
        }
      end

      it do
        is_expected.to contain_shellvar('yum_cron ERROR_LEVEL').with(ensure: 'present',
                                                                     target: '/etc/sysconfig/yum-cron',
                                                                     notify: 'Service[yum-cron]',
                                                                     variable: 'ERROR_LEVEL',
                                                                     value: '1')
      end
    end
  when '5'
    EL5_CONFIGS.each do |config|
      it "should set #{config[:name]} to #{config[:value]}" do
        is_expected.to contain_shellvar("yum_cron #{config[:name]}").with(ensure: 'present',
                                                                          target: '/etc/sysconfig/yum-cron',
                                                                          notify: 'Service[yum-cron]',
                                                                          variable: config[:name],
                                                                          value: config[:value])
      end
    end

    it { is_expected.to have_yum_cron_config_resource_count(0) }
    it { is_expected.to have_shellvar_resource_count(EL5_CONFIGS.size) }

    context 'when enable => false' do
      let(:params) { { enable: false } }

      EL5_CONFIGS.each do |config|
        it 'does not notify Service[yum-cron]' do
          is_expected.to contain_shellvar("yum_cron #{config[:name]}").without_notify
        end
      end
    end
  end

  context 'ensure => absent' do
    let(:params) { { ensure: 'absent' } }

    it { is_expected.to have_yum_cron_config_resource_count(0) }
    it { is_expected.to have_shellvar_resource_count(0) }
  end

  if facts[:operatingsystem] =~ %r{Scientific}
    it do
      is_expected.to contain_file_line('disable yum-autoupdate').with(path: '/etc/sysconfig/yum-autoupdate',
                                                                      line: 'ENABLED=false',
                                                                      match: '^ENABLED=.*')
    end

    context "yum_autoupdate_ensure => 'absent'" do
      let(:params) { { yum_autoupdate_ensure: 'absent' } }

      it { is_expected.not_to contain_file_line('disable yum-autoupdate') }
    end

    context "yum_autoupdate_ensure => 'undef'" do
      let(:params) { { yum_autoupdate_ensure: 'undef' } }

      it { is_expected.not_to contain_file_line('disable yum-autoupdate') }
    end

    context "yum_autoupdate_ensure => 'UNSET'" do
      let(:params) { { yum_autoupdate_ensure: 'UNSET' } }

      it { is_expected.not_to contain_file_line('disable yum-autoupdate') }
    end
  else
    it { is_expected.not_to contain_file_line('disable yum-autoupdate') }
  end
end
