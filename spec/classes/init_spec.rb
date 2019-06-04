require 'spec_helper'
describe 'vas_local_user' do
  platforms = {
    'RedHat' => {
      :default_manage_package => true,
    },
    'Debian' => {
      :default_manage_package => true,
    },
    'Ubuntu' => {
      :default_manage_package => true,
    },
    'OpenSuSE' => {
      :default_manage_package => true,
    },
    'SLES' => {
      :default_manage_package => false,
    }
  }

  user_params = {
    :users => {
      'user1' => {
        'ensure' => 'present',
        'uid' => '1001',
        'gid' => '100',
        'home' => '/var/lib/user1',
      }
    },
    :ssh_keys => {
      'user1' => {
        'ensure' => 'present',
        'user' => 'user1',
        'type' => 'ssh-rsa',
        'target' => '/var/lib/user1/.ssh/authorized_keys',
        'key' => 'AAAAThisKeyIsNotValid',
      }
    }
  }

  context 'with defaults for all parameters' do
    platforms.sort.each do |k, v|
      context "where osfamily is <#{k}>" do
        let :facts do
          { :operatingsystem => k }
        end

        it { should contain_class('vas_local_user') }
        it { should have_user_count(0) }

        if v[:default_manage_package] == true
          it { should contain_package('libuser') }
        else
          it { should_not contain_package('libuser') }
        end
      end
    end
  end

  describe 'with defaults and one user in users and one in ssh_keys' do
    platforms.sort.each do |k, _v|
      let :default_facts do { :operatingsystem => k } end

      context "where osfamily is <#{k}>" do
        let :facts do
          default_facts
        end

        let :params do
          user_params
        end

        context 'with manage_package' do
          ['false', false].each do |value|
            context "set to #{value}" do
              let :pre_condition do
                'class vas { }
                include vas'
              end
              let :params do
                {
                  :manage_package => value,
                }
              end

              it { should_not contain_package('libuser') }
            end
          end
        end

        context 'with manage_users' do
          ['false', false].each do |value|
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

              it { should_not contain_user('user1') }
              it { should_not contain_ssh_authorized_key('user1') }
            end
          end
        end

        context 'with VAS not installed' do
          context 'and not managed' do
            it { should contain_user('user1') }
            it { should contain_ssh_authorized_key('user1') }
          end

          context 'and managed' do
            let :pre_condition do
              'class vas { }
              include vas'
            end

            it { should contain_user('user1').that_comes_before('Class[vas]') }
            it { should contain_user('user1').that_requires('Package[libuser]') }
            it { should contain_ssh_authorized_key('user1') }
          end
        end

        context 'with VAS installed' do
          let :facts do
            default_facts.merge(
              {
                :vas_version => '4.1.5.23233',
              }
            )
          end

          context 'and managed' do
            let :pre_condition do
              'class vas { }
              include vas'
            end

            it { should contain_user('user1').that_comes_before('Class[vas]') }
            it { should contain_user('user1').that_requires('Package[libuser]') }
            it { should contain_ssh_authorized_key('user1') }
          end

          # Disable manage_package to ensure this state is fulfilled
          context 'and not managed without libuser support' do
            let :params do
              user_params.merge(
                {
                  :manage_package => false,
                }
              )
            end

            let :facts do
              default_facts.merge(
                {
                  :vas_version => '4.1.5.23233',
                  :vas_local_user_libuser => 'no'
                }
              )
            end

            it { should_not contain_user('user1') }
            it { should_not contain_ssh_authorized_key('user1') }
          end

          context 'and not managed with libuser support' do
            let :facts do
              default_facts.merge(
                {
                  :vas_version => '4.1.5.23233',
                  :vas_local_user_libuser => 'yes'
                }
              )
            end

            it { should contain_user('user1') }
            it { should contain_ssh_authorized_key('user1') }
          end
        end
      end
    end
  end

  let :default_facts do
    { :operatingsystem => 'RedHat' }
  end
  let(:facts) { default_facts }

  context 'with manage_package set to true and package_name set' do
    let :facts do
      default_facts
    end
    let :params do
      {
        :manage_package => true,
        :package_name => 'libuserpackage',
      }
    end

    it { should contain_package('libuserpackage') }
    it { should_not contain_package('libuser') }
  end

  describe 'hiera merge' do
    describe '"user1" and "user2" and user1\'s ssh_authorized_keys' do
      context 'on system with VAS managed and not installed' do
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
