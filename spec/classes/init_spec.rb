require 'spec_helper'
describe 'vas_local_user' do
  let :default_facts do
    {
      :kernel                     => 'Linux',
      :osfamily                   => 'RedHat',
      :lsbmajdistrelease          => '6',
      :operatingsystemmajrelease  => '6',
    }
  end

  let(:facts) { default_facts }

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

    context 'with manage_users' do
      ['false',false].each do |value|
        context "set to #{value}" do
          let :pre_condition do
            'class vas { }
            include vas'
          end
          let :params do
            {
              :manage_users => value,
            }
          end
          let :facts do
            default_facts.merge(
              {
                :fqdn => 'vasenabled.example.local'
              }
            )
          end

          it { should_not contain_user('user1') }
        end
      end
    end

    context 'on system with VAS managed but not installed' do
      let :pre_condition do
        'class vas { }
        include vas'
      end
      let :facts do
        default_facts.merge(
          {
            :fqdn => 'vasenabled.example.local'
          }
        )
      end

      it do
        should contain_user('user1').with(
          {
            'ensure'    => 'present',
            'uid'         => '1001',
            'gid'         => '100',
            'home'        => '/var/lib/user1',
            'managehome'  => 'true',
            'forcelocal'  => 'true',
          }
        )
      end
      it { should contain_user('user1').that_comes_before('Class[vas]') }
    end

    context 'on system with VAS managed and installed without libuser' do
      let :pre_condition do
        'class vas { }
        include vas'
      end
      let :facts do
        default_facts.merge(
          {
            :fqdn => 'vasenabled.example.local',
            :vas_version => '4.1.0.21518'
          }
        )
      end

      it { should_not contain_user('user1') }
    end

    context 'on system with VAS managed and installed with libuser' do
      let :pre_condition do
        'class vas { }
        include vas'
      end
      let :facts do
        default_facts.merge(
          {
            :fqdn => 'vasenabled.example.local',
            :vas_version => '4.1.0.21518',
            :vas_local_user_libuser => 'yes',
          }
        )
      end

      it do
        should contain_user('user1').with(
          {
            'ensure'    => 'present',
            'uid'         => '1001',
            'gid'         => '100',
            'home'        => '/var/lib/user1',
            'managehome'  => 'true',
            'forcelocal'  => 'true',
          }
        )
      end
    end

    context 'on system without VAS managed but installed' do
      let :facts do
        default_facts.merge(
          {
            :fqdn => 'vasenabled.example.local',
            :vas_version => '4.1.0.21518'
          }
        )
      end

      it { should_not contain_user('user1') }
    end

    context 'on system without VAS' do
      it do
        should contain_user('user1').with(
          {
            'ensure'    => 'present',
            'uid'         => '1001',
            'gid'         => '100',
            'home'        => '/var/lib/user1',
            'managehome'  => 'true',
          }
        )
      end
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
        :ssh_keys => {
          'user1'   => {
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
      let :pre_condition do
        'class vas { }
        include vas'
      end
      let :facts do
        default_facts.merge(
          {
            :fqdn => 'vasenabled.example.local'
          }
        )
      end

      it { should contain_user('user1') }
      it { should contain_ssh_authorized_key('user1') }
    end

    context 'on system without VAS managed but installed' do
      let :facts do
        default_facts.merge(
          {
            :fqdn => 'vasenabled.example.local',
            :vas_version => '4.1.0.21518'
          }
        )
      end

      it { should_not contain_user('user1') }
      it { should_not contain_ssh_authorized_key('user1') }
    end

    context 'on system with VAS managed and installed' do
      let :pre_condition do
        'class vas { }
        include vas'
      end
      let :facts do
        default_facts.merge(
          {
            :fqdn => 'vasenabled.example.local',
            :vas_version => '4.1.0.21518'
          }
        )
      end

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
        let :pre_condition do
          'class vas { }
          include vas'
        end
        let :facts do
          default_facts.merge(
            {
              :fqdn => 'vasenabled-user.example.local',
              :spectest => 'user1'
            }
          )
        end

        it { should contain_user('user1') }
        it { should contain_user('user2') }
        it { should contain_ssh_authorized_key('user1') }
        it { should_not contain_ssh_authorized_key('user2') }
      end

      context 'on system with VAS managed and installed' do
        let :pre_condition do
          'class vas { }
          include vas'
        end
        let :facts do
          default_facts.merge(
            {
              :fqdn => 'vasenabled-user.example.local',
              :spectest => 'user1',
              :vas_version => '4.1.0.21518'
            }
          )
        end

        it { should_not contain_user('user1') }
        it { should_not contain_user('user2') }
        it { should_not contain_ssh_authorized_key('user1') }
        it { should_not contain_ssh_authorized_key('user2') }
      end

      context 'on system without VAS managed but installed' do
        let :facts do
          default_facts.merge(
            {
              :fqdn => 'vasenabled-user.example.local',
              :spectest => 'user1',
              :vas_version => '4.1.0.21518'
            }
          )
        end

        it { should_not contain_user('user1') }
        it { should_not contain_user('user2') }
        it { should_not contain_ssh_authorized_key('user1') }
        it { should_not contain_ssh_authorized_key('user2') }
      end

      context 'on system without VAS' do
        let :facts do
          default_facts.merge(
            {
              :fqdn => 'vasdisabled-user.example.local',
              :spectest => 'user1'
            }
          )
        end

        it { should contain_user('user1') }
        it { should contain_user('user2') }
        it { should contain_ssh_authorized_key('user1') }
        it { should_not contain_ssh_authorized_key('user2') }
      end
    end

    describe 'with users "user1" and "user2" managed and ssh_authorized_keys for both' do
      context 'on system with VAS managed but not installed' do
        let :pre_condition do
          'class vas { }
          include vas'
        end
        let :facts do
          default_facts.merge(
            {
              :fqdn => 'vasenabled-userkey.example.local',
              :spectest => 'user1'
            }
          )
        end

        it { should contain_user('user1') }
        it { should contain_user('user2') }
        it { should contain_ssh_authorized_key('user1') }
        it { should contain_ssh_authorized_key('user2') }
      end

      context 'on system with VAS managed and installed' do
        let :pre_condition do
          'class vas { }
          include vas'
        end
        let :facts do
          default_facts.merge(
            {
              :fqdn => 'vasenabled-userkey.example.local',
              :spectest => 'user1',
              :vas_version => '4.1.0.21518'
            }
          )
        end

        it { should_not contain_user('user1') }
        it { should_not contain_user('user2') }
        it { should_not contain_ssh_authorized_key('user1') }
        it { should_not contain_ssh_authorized_key('user2') }
      end

      context 'on system without VAS managed but installed' do
        let :facts do
          default_facts.merge(
            {
              :fqdn => 'vasenabled-userkey.example.local',
              :spectest => 'user1',
              :vas_version => '4.1.0.21518'
            }
          )
        end

        it { should_not contain_user('user1') }
        it { should_not contain_user('user2') }
        it { should_not contain_ssh_authorized_key('user1') }
        it { should_not contain_ssh_authorized_key('user2') }
      end

      context 'on system without VAS' do
        let :facts do
          default_facts.merge(
            {
            :fqdn => 'vasdisabled-userkey.example.local',
            :spectest => 'user1'
            }
          )
        end

        it { should contain_user('user1') }
        it { should contain_user('user2') }
        it { should contain_ssh_authorized_key('user1') }
        it { should contain_ssh_authorized_key('user2') }
      end
    end
  end
end
