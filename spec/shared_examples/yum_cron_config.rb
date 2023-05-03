# frozen_string_literal: true

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
      { name: 'base/exclude', value: '' }
    ].freeze
  end

  case facts[:os]['release']['major'].to_s
  when '7'
    EL7_CONFIGS.each do |config|
      it "sets #{config[:name]} to #{config[:value]}" do
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

    context 'when extra_configs defined' do
      let(:params) do
        {
          extra_configs: {
            'email/email_from' => { 'value' => 'foo@bar.com' }
          }
        }
      end

      it do
        is_expected.to contain_yum_cron_config('email/email_from').with(value: 'foo@bar.com',
                                                                        notify: 'Service[yum-cron]')
      end
    end
  end

  context 'when ensure => absent' do
    let(:params) { { ensure: 'absent' } }

    it { is_expected.to have_yum_cron_config_resource_count(0) }
  end

  if facts[:os]['name'] =~ %r{Scientific}
    it do
      is_expected.to contain_file_line('disable yum-autoupdate').with(path: '/etc/sysconfig/yum-autoupdate',
                                                                      line: 'ENABLED=false',
                                                                      match: '^ENABLED=.*')
    end

    context "when yum_autoupdate_ensure => 'absent'" do
      let(:params) { { yum_autoupdate_ensure: 'absent' } }

      it { is_expected.not_to contain_file_line('disable yum-autoupdate') }
    end

    context "when yum_autoupdate_ensure => 'undef'" do
      let(:params) { { yum_autoupdate_ensure: 'undef' } }

      it { is_expected.not_to contain_file_line('disable yum-autoupdate') }
    end

    context "when yum_autoupdate_ensure => 'UNSET'" do
      let(:params) { { yum_autoupdate_ensure: 'UNSET' } }

      it { is_expected.not_to contain_file_line('disable yum-autoupdate') }
    end
  else
    it { is_expected.not_to contain_file_line('disable yum-autoupdate') }
  end
end
