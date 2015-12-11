require 'spec_helper'
describe 'vas_local_user' do

  let :facts do
    {
      :kernel                     => 'Linux',
      :osfamily                   => 'RedHat',
      :lsbmajdistrelease          => '6',
      :operatingsystemmajrelease  => '6',
    }
  end

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

      it 'should contain user user1' do
        facts.merge!({'fqdn' => 'vasenabled.example.local'})
        should contain_user('user1').with({
          'ensure'    => 'present',
          'uid'         => '1001',
          'gid'         => '100',
          'home'        => '/var/lib/user1',
          'managehome'  => 'true',
          'forcelocal'  => 'true',
        })
        should contain_user('user1').that_comes_before('Class[vas]')
      end
    end

    context 'on system with VAS managed and installed' do
      let(:pre_condition) {
          'class vas { }
          include vas'
      }

      it 'should not contain user1' do
        facts.merge!({'vas_version' => '4.1.0.21518',
                      'fqdn' => 'vasenabled.example.local'})
        should_not contain_user('user1')
      end
    end

    context 'on system without VAS managed but installed' do

      it 'should not contain user1' do
        facts.merge!({'vas_version' => '4.1.0.21518',
                      'fqdn' => 'vasenabled.example.local'})
        should_not contain_user('user1')
      end
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

      it 'should contain user user1' do
        facts.merge!({'fqdn' => 'vasenabled.example.local'})
        should contain_user('user1')
      end
      it 'should contain user1\'s ssh_authorized_keys' do
        facts.merge!({'fqdn' => 'vasenabled.example.local'})
        should contain_ssh_authorized_key('user1')
      end
    end

    context 'on system without VAS managed but installed' do

      it 'should not contain user1' do
        facts.merge!({'vas_version' => '4.1.0.21518',
                      'fqdn' => 'vasenabled.example.local'})
        should_not contain_user('user1')
      end

      it 'should not contain user1\'s ssh_authorized_keys' do
        facts.merge!({'vas_version' => '4.1.0.21518',
                      'fqdn' => 'vasenabled.example.local'})
        should_not contain_ssh_authorized_key('user1')
      end

    end

    context 'on system with VAS managed and installed' do
      let(:pre_condition) {
          'class vas { }
          include vas'
      }

      it 'should not contain user1' do
        facts.merge!({'vas_version' => '4.1.0.21518',
                      'fqdn' => 'vasenabled.example.local'})
        should_not contain_user('user1')
      end

      it 'should not contain user1\'s ssh_authorized_keys' do
        facts.merge!({'vas_version' => '4.1.0.21518',
                      'fqdn' => 'vasenabled.example.local'})
        should_not contain_ssh_authorized_key('user1')
      end

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

        it 'should contain user user1' do
          facts.merge!({'fqdn'      => 'vasenabled-user.example.local',
                        'spectest'  => 'user1'})
          should contain_user('user1')
        end
        it 'should contain user user2' do
          facts.merge!({'fqdn'      => 'vasenabled-user.example.local',
                        'spectest'  => 'user1'})
          should contain_user('user2')
        end
        it 'should contain ssh_authorized_keys for user1' do
          facts.merge!({'fqdn'      => 'vasenabled-user.example.local',
                        'spectest'  => 'user1'})
          should contain_ssh_authorized_key('user1')
        end
        it 'should not contain ssh_authorized_keys for user2' do
          facts.merge!({'fqdn'      => 'vasenabled-user.example.local',
                        'spectest'  => 'user1'})
          should_not contain_ssh_authorized_key('user2')
        end

      end

      context 'on system with VAS managed and installed' do
        let(:pre_condition) {
            'class vas { }
            include vas'
        }

        it 'should not contain user user1' do
          facts.merge!({'vas_version' => '4.1.0.21518',
                        'fqdn' => 'vasenabled-user.example.local',
                        'spectest'  => 'user1'})
          should_not contain_user('user1')
        end
        it 'should not contain user user2' do
          facts.merge!({'vas_version' => '4.1.0.21518',
                        'fqdn' => 'vasenabled-user.example.local',
                        'spectest'  => 'user1'})
          should_not contain_user('user2')
        end
        it 'should not contain ssh_authorized_keys for user2' do
          facts.merge!({'vas_version' => '4.1.0.21518',
                        'fqdn' => 'vasenabled-user.example.local',
                        'spectest'  => 'user1'})
          should_not contain_ssh_authorized_key('user1')
        end
        it 'should not contain ssh_authorized_keys for user2' do
          facts.merge!({'fqdn'      => 'vasenabled-user.example.local',
                        'spectest'  => 'user1'})
          should_not contain_ssh_authorized_key('user2')
        end

      end

      context 'on system without VAS managed but installed' do

        it 'should not contain user user1' do
          facts.merge!({'vas_version' => '4.1.0.21518',
                        'fqdn' => 'vasenabled-user.example.local',
                        'spectest'  => 'user1'})
          should_not contain_user('user1')
        end
        it 'should not contain user user2' do
          facts.merge!({'vas_version' => '4.1.0.21518',
                        'fqdn' => 'vasenabled-user.example.local',
                        'spectest'  => 'user1'})
          should_not contain_user('user2')
        end
        it 'should not contain ssh_authorized_keys for user2' do
          facts.merge!({'vas_version' => '4.1.0.21518',
                        'fqdn' => 'vasenabled-user.example.local',
                        'spectest'  => 'user1'})
          should_not contain_ssh_authorized_key('user1')
        end
        it 'should not contain ssh_authorized_keys for user2' do
          facts.merge!({'fqdn'      => 'vasenabled-user.example.local',
                        'spectest'  => 'user1'})
          should_not contain_ssh_authorized_key('user2')
        end

      end

      context 'on system without VAS' do
        it 'should contain user user1' do
          facts.merge!({'fqdn'      => 'vasdisabled-user.example.local',
                        'spectest'  => 'user1'})
          should contain_user('user1')
        end
        it 'should contain user user2' do
          facts.merge!({'fqdn'      => 'vasdisabled-user.example.local',
                        'spectest'  => 'user1'})
          should contain_user('user2')
        end
        it 'should contain ssh_authorized_keys for user1' do
          facts.merge!({'fqdn'      => 'vasdisabled-user.example.local',
                        'spectest'  => 'user1'})
          should contain_ssh_authorized_key('user1')
        end
        it 'should not contain ssh_authorized_keys for user2' do
          facts.merge!({'fqdn'      => 'vasdisabled-user.example.local',
                        'spectest'  => 'user1'})
          should_not contain_ssh_authorized_key('user2')
        end

      end

    end

    describe 'with users "user1" and "user2" managed and ssh_authorized_keys for both' do

      context 'on system with VAS managed but not installed' do
        let(:pre_condition) {
            'class vas { }
            include vas'
        }

        it 'should contain user user1' do
          facts.merge!({'fqdn'      => 'vasenabled-userkey.example.local',
                        'spectest'  => 'user1'})
          should contain_user('user1')
        end
        it 'should contain user user2' do
          facts.merge!({'fqdn'      => 'vasenabled-userkey.example.local',
                        'spectest'  => 'user1'})
          should contain_user('user2')
        end
        it 'should contain ssh_authorized_keys for user1' do
          facts.merge!({'fqdn'      => 'vasenabled-userkey.example.local',
                        'spectest'  => 'user1'})
          should contain_ssh_authorized_key('user1')
        end
        it 'should contain ssh_authorized_keys for user2' do
          facts.merge!({'fqdn'      => 'vasenabled-userkey.example.local',
                        'spectest'  => 'user1'})
          should contain_ssh_authorized_key('user2')
        end
      end

      context 'on system with VAS managed and installed' do
        let(:pre_condition) {
            'class vas { }
            include vas'
        }

        it 'should not contain user user1' do
          facts.merge!({'vas_version' => '4.1.0.21518',
                        'fqdn'        => 'vasenabled-userkey.example.local',
                        'spectest'    => 'user1'})
          should_not contain_user('user1')
        end
        it 'should not contain user user2' do
          facts.merge!({'vas_version' => '4.1.0.21518',
                        'fqdn'        => 'vasenabled-userkey.example.local',
                        'spectest'    => 'user1'})
          should_not contain_user('user2')
        end
        it 'should not contain ssh_authorized_keys for user1' do
          facts.merge!({'vas_version' => '4.1.0.21518',
                        'fqdn'        => 'vasenabled-userkey.example.local',
                        'spectest'    => 'user1'})
          should_not contain_ssh_authorized_key('user1')
        end
        it 'should not contain ssh_authorized_keys for user2' do
          facts.merge!({'vas_version' => '4.1.0.21518',
                        'fqdn'        => 'vasenabled-userkey.example.local',
                        'spectest'    => 'user1'})
          should_not contain_ssh_authorized_key('user2')
        end
      end

      context 'on system without VAS managed but installed' do

        it 'should not contain user user1' do
          facts.merge!({'vas_version' => '4.1.0.21518',
                        'fqdn'        => 'vasenabled-userkey.example.local',
                        'spectest'    => 'user1'})
          should_not contain_user('user1')
        end
        it 'should not contain user user2' do
          facts.merge!({'vas_version' => '4.1.0.21518',
                        'fqdn'        => 'vasenabled-userkey.example.local',
                        'spectest'    => 'user1'})
          should_not contain_user('user2')
        end
        it 'should not contain ssh_authorized_keys for user1' do
          facts.merge!({'vas_version' => '4.1.0.21518',
                        'fqdn'        => 'vasenabled-userkey.example.local',
                        'spectest'    => 'user1'})
          should_not contain_ssh_authorized_key('user1')
        end
        it 'should not contain ssh_authorized_keys for user2' do
          facts.merge!({'vas_version' => '4.1.0.21518',
                        'fqdn'        => 'vasenabled-userkey.example.local',
                        'spectest'    => 'user1'})
          should_not contain_ssh_authorized_key('user2')
        end
      end

      context 'on system without VAS' do
        it 'should contain user user1' do
          facts.merge!({'fqdn'      => 'vasdisabled-userkey.example.local',
                        'spectest'  => 'user1'})
          should contain_user('user1')
        end
        it 'should contain user user2' do
          facts.merge!({'fqdn'      => 'vasdisabled-userkey.example.local',
                        'spectest'  => 'user1'})
          should contain_user('user2')
        end
        it 'should contain ssh_authorized_keys for user1' do
          facts.merge!({'fqdn'      => 'vasdisabled-userkey.example.local',
                        'spectest'  => 'user1'})
          should contain_ssh_authorized_key('user1')
        end
        it 'should contain ssh_authorized_keys for user2' do
          facts.merge!({'fqdn'      => 'vasdisabled-userkey.example.local',
                        'spectest'  => 'user1'})
          should contain_ssh_authorized_key('user2')
        end

      end
    end
  end
end
