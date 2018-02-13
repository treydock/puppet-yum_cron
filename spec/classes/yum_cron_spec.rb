require 'spec_helper'

describe 'yum_cron' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:params) {{ }}

      it { should create_class('yum_cron') }
      it { should contain_class('yum_cron::params') }

      it { should contain_class('yum_cron::install').that_comes_before('Class[yum_cron::config]') }
      it { should contain_class('yum_cron::config').that_comes_before('Class[yum_cron::service]') }
      it { should contain_class('yum_cron::service') }

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
              expect { should compile }.to raise_error(/expects a Boolean value/)
            end
          end
        end

        # Test string validation
        [
          :mailto,
          :systemname,
          :email_host,
        ].each do |param|
          context "#{param} => false" do
            let(:params) {{ param => false }}
            it 'should raise an error' do
              expect { should compile }.to raise_error(/expects a String value/)
            end
          end
        end

        # Test string validation
        [
          :update_messages,
        ].each do |param|
          context "#{param} => false" do
            let(:params) {{ param => false }}
            it 'should raise an error' do
              expect { should compile }.to raise_error(/expects a match for Enum/)
            end
          end
        end

        context "update_cmd => invalid" do
          let(:params) {{ :update_cmd => "invalid" }}
          it "should raise an error" do
            expect { should compile }.to raise_error(/expects a match for Yum_cron::Update_cmd/)
          end
        end

        # Test pattern validation
        [
          :days_of_week,
          :cleanday,
        ].each do |param|
          context "#{param} => false" do
            let(:params) {{ param => false }}
            it 'should raise an error' do
              expect { should compile }.to raise_error(/expects a match for Pattern/)
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
              expect { should compile }.to raise_error(/expects a Hash value/)
            end
          end
        end
      end
    end
  end
end
