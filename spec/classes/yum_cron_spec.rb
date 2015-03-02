require 'spec_helper'

describe 'yum_cron' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:params) {{ }}

      it { should create_class('yum_cron') }
      it { should contain_class('yum_cron::params') }

      it { should contain_anchor('yum_cron::start').that_comes_before('Class[yum_cron::install]') }
      it { should contain_class('yum_cron::install').that_comes_before('Class[yum_cron::config]') }
      it { should contain_class('yum_cron::config').that_comes_before('Class[yum_cron::service]') }
      it { should contain_class('yum_cron::service').that_comes_before('Anchor[yum_cron::end]') }
      it { should contain_anchor('yum_cron::end') }

      it_behaves_like 'yum_cron::install', facts
      it_behaves_like 'yum_cron::config', facts
      it_behaves_like 'yum_cron::service', facts

      describe 'validations' do
        # Test boolean validation
        [
          :enable,
          :download_updates,
          :apply_updates,
        ].each do |param|
          context "#{param} => 'foo'" do
            let(:params) {{ param => 'foo' }}
            it 'should raise an error' do
              expect { should compile }.to raise_error(/is not a boolean/)
            end
          end
        end

        # Test string validation
        [
          :mailto,
          :systemname,
          :days_of_week,
          :cleanday,
          :update_cmd,
          :update_messages,
          :email_host,
        ].each do |param|
          context "#{param} => false" do
            let(:params) {{ param => false }}
            it 'should raise an error' do
              expect { should compile }.to raise_error(/is not a string/)
            end
          end
        end

        # Test hash validation
        [
          :extra_configs,
        ].each do |param|
          context "#{param} => 'foo'" do
            let(:params) {{ param => 'foo' }}
            it 'should raise an error' do
              expect { should compile }.to raise_error(/is not a Hash/)
            end
          end
        end
      end
    end
  end
end
