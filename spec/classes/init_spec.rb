require 'spec_helper'
describe 'vas_local_user' do

  let :default_facts do
    {
      :kernel                     => 'Linux',
      :osfamily                   => 'RedHat',
      :lsbmajdistrelease          => '6',
      :operatingsystemmajrelease  => '6',
      :fqdn                       => 'vasenabled.example.local',
    }
  end

  let (:facts) { default_facts }

  context 'with defaults for all parameters' do
    it { should contain_class('vas_local_user') }
  end

  describe 'with a single user \'user1\'' do
    let :params do
      {
        :users => {
          'user1' => {
            'ensure'  => 'present',
            'uid'     => '1001',
            'gid'     => '100',
            'home'    => '/var/lib/user1',
          },
        },
      }
    end

    context 'on system with VAS managed but not installed' do
      let(:pre_condition) {
          'class vas { }
          include vas'
      }
#      let (:facts) { validation_facts.merge({:fqdn => 'vasenabled.example.local'}) }

      it { should contain_user('user1').with({
          'ensure'    => 'present',
          'uid'         => '1001',
          'gid'         => '100',
          'home'        => '/var/lib/user1',
          'managehome'  => 'true',
          'forcelocal'  => 'true',
        }) }
      it { should contain_user('user1').that_comes_before('Class[vas]') }
    end

    context 'on system with VAS managed and installed' do
      let(:pre_condition) {
          'class vas { }
          include vas'
      }
#      let (:facts) { validation_facts.merge({:fqdn => 'vasenabled.example.local',
#                                             :vas_version => '4.1.0.21518'}) }

      let (:facts) { default_facts.merge({:vas_version => '4.1.0.21518'}) }

      it { should_not contain_user('user1') }
    end

    context 'on system without VAS managed but installed' do
#      let (:facts) { validation_facts.merge({:fqdn => 'vasenabled.example.local',
#                                             :vas_version => '4.1.0.21518'}) }
      let (:facts) { default_facts.merge({:vas_version => '4.1.0.21518'}) }


      it { should_not contain_user('user1') }
    end

    context 'on system without VAS' do

      it { should contain_user('user1').with({
        'ensure'    => 'present',
        'uid'         => '1001',
        'gid'         => '100',
        'home'        => '/var/lib/user1',
        'managehome'  => 'true',
      })}

    end
  end

  describe 'with a single user \'user1\' and its ssh_authorized_key managed' do
    let :params do
      {
        :users    => {
          'user1' => {
            'ensure'  => 'present',
            'uid'     => '1001',
            'gid'     => '100',
            'home'    => '/var/lib/user1',
          },
        },
       :ssh_keys  => {
          'user1' => {
            'ensure'  => 'present',
            'user'    => 'user1',
            'type'    => 'ssh-rsa',
            'target'  => '/var/lib/user1/.ssh/authorized_keys',
            'key'     => 'AAAAThisKeyIsNotValid',
          },
        },
      }
    end

    context 'on system with VAS managed but not installed' do
      let(:pre_condition) {
          'class vas { }
          include vas'
      }
#      let (:facts) { validation_facts.merge({:fqdn => 'vasenabled.example.local'}) }

      it { should contain_user('user1') }
      it { should contain_ssh_authorized_key('user1') }
    end

    context 'on system without VAS managed but installed' do
#      let (:facts) { validation_facts.merge({:fqdn => 'vasenabled.example.local',
#                                             :vas_version => '4.1.0.21518'}) }

      let (:facts) { default_facts.merge({:vas_version => '4.1.0.21518'}) }

      it { should_not contain_user('user1') }
      it { should_not contain_ssh_authorized_key('user1') }
    end

    context 'on system with VAS managed and installed' do
      let(:pre_condition) {
          'class vas { }
          include vas'
      }
#      let (:facts) { validation_facts.merge({:fqdn => 'vasenabled.example.local',
#                                             :vas_version => '4.1.0.21518'}) }

      let (:facts) { default_facts.merge({:vas_version => '4.1.0.21518'}) }

      it { should_not contain_user('user1') }
      it { should_not contain_ssh_authorized_key('user1') }
    end

    context 'on system without VAS' do

      it { should contain_user('user1') }
      it { should contain_ssh_authorized_key('user1') }
    end

  end

  describe 'hiera merge' do

    describe '"user1" and "user2" and user1\'s ssh_authorized_keys' do

      context 'on system with VAS managed but not installed' do
        let(:pre_condition) {
            'class vas { }
            include vas'
        }
#        let (:facts) { validation_facts.merge({:fqdn => 'vasenabled-user.example.local',
#                                               :spectest => 'user1'}) }

        let (:facts) { default_facts.merge({:fqdn        => 'vasenabled-user.example.local',
                                            :spectest    => 'user1'}) }

        it { should contain_user('user1') }
        it { should contain_user('user2') }
        it { should contain_ssh_authorized_key('user1') }
        it { should_not contain_ssh_authorized_key('user2') }
      end

      context 'on system with VAS managed and installed' do
        let(:pre_condition) {
            'class vas { }
            include vas'
        }
#        let (:facts) { validation_facts.merge({:fqdn => 'vasenabled-user.example.local',
#                                               :spectest => 'user1',
#                                               :vas_version => '4.1.0.21518'}) }

        let (:facts) { default_facts.merge({:fqdn        => 'vasenabled-user.example.local',
                                            :spectest    => 'user1',
                                            :vas_version => '4.1.0.21518'}) }

        it { should_not contain_user('user1') }
        it { should_not contain_user('user2') }
        it { should_not contain_ssh_authorized_key('user1') }
        it { should_not contain_ssh_authorized_key('user2') }
      end

      context 'on system without VAS managed but installed' do
#        let (:facts) { validation_facts.merge({:fqdn => 'vasenabled-user.example.local',
#                                               :spectest => 'user1',
#                                               :vas_version => '4.1.0.21518'}) }

        let (:facts) { default_facts.merge({:fqdn        => 'vasenabled-user.example.local',
                                            :spectest    => 'user1',
                                            :vas_version => '4.1.0.21518'}) }

        it { should_not contain_user('user1') }
        it { should_not contain_user('user2') }
        it { should_not contain_ssh_authorized_key('user1') }
        it { should_not contain_ssh_authorized_key('user2') }
      end

      context 'on system without VAS' do
#        let (:facts) { validation_facts.merge({:fqdn => 'vasdisabled-user.example.local',
#                                               :spectest => 'user1'}) }

        let (:facts) { default_facts.merge({:fqdn        => 'vasdisabled-user.example.local',
                                            :spectest    => 'user1'}) }

        it { should contain_user('user1') }
        it { should contain_user('user2') }
        it { should contain_ssh_authorized_key('user1') }
        it { should_not contain_ssh_authorized_key('user2') }
      end

    end

    describe 'with users "user1" and "user2" managed and ssh_authorized_keys for both' do

      context 'on system with VAS managed but not installed' do
        let(:pre_condition) {
            'class vas { }
            include vas'
        }
#        let (:facts) { validation_facts.merge({:fqdn => 'vasenabled-userkey.example.local',
#                                               :spectest => 'user1'}) }

        let (:facts) { default_facts.merge({:fqdn        => 'vasenabled-userkey.example.local',
                                            :spectest    => 'user1'}) }

        it { should contain_user('user1') }
        it { should contain_user('user2') }
        it { should contain_ssh_authorized_key('user1') }
        it { should contain_ssh_authorized_key('user2') }
      end

      context 'on system with VAS managed and installed' do
        let(:pre_condition) {
            'class vas { }
            include vas'
        }
#        let (:facts) { validation_facts.merge({:fqdn => 'vasenabled-userkey.example.local',
#                                               :spectest => 'user1',
#                                               :vas_version => '4.1.0.21518'}) }

        let (:facts) { default_facts.merge({:fqdn        => 'vasenabled-userkey.example.local',
                                            :spectest    => 'user1',
                                            :vas_version => '4.1.0.21518'}) }

        it { should_not contain_user('user1') }
        it { should_not contain_user('user2') }
        it { should_not contain_ssh_authorized_key('user1') }
        it { should_not contain_ssh_authorized_key('user2') }
      end

      context 'on system without VAS managed but installed' do
#        let (:facts) { validation_facts.merge({:fqdn => 'vasenabled-userkey.example.local',
#                                               :spectest => 'user1',
#                                               :vas_version => '4.1.0.21518'}) }

        let (:facts) { default_facts.merge({:fqdn        => 'vasenabled-userkey.example.local',
                                            :spectest    => 'user1',
                                            :vas_version => '4.1.0.21518'}) }

        it { should_not contain_user('user1') }
        it { should_not contain_user('user2') }
        it { should_not contain_ssh_authorized_key('user1') }
        it { should_not contain_ssh_authorized_key('user2') }
      end

      context 'on system without VAS' do
#        let (:facts) { validation_facts.merge({:fqdn => 'vasdisabled-userkey.example.local',
#                                               :spectest => 'user1'}) }

        let (:facts) { default_facts.merge({:fqdn => 'vasdisabled-userkey.example.local',
                                            :spectest => 'user1'}) }

        it { should contain_user('user1') }
        it { should contain_user('user2') }
        it { should contain_ssh_authorized_key('user1') }
        it { should contain_ssh_authorized_key('user2') }
      end
    end
  end
end
