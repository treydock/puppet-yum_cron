# frozen_string_literal: true

require 'spec_helper'

describe 'yum_cron' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:params) { {} }

      it { is_expected.to create_class('yum_cron') }

      it { is_expected.to contain_class('yum_cron::install').that_comes_before('Class[yum_cron::config]') }
      it { is_expected.to contain_class('yum_cron::config').that_comes_before('Class[yum_cron::service]') }
      it { is_expected.to contain_class('yum_cron::service') }

      it_behaves_like 'yum_cron::install', facts
      it_behaves_like 'yum_cron::config', facts
      it_behaves_like 'yum_cron::service', facts

      context 'when ensure => absent' do
        let(:params) { { ensure: 'absent' } }

        it { is_expected.not_to contain_class('yum_cron::config') }
      end
    end
  end
end
