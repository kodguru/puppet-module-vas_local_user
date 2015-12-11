# == Class: vas_local_user
#
class vas_local_user(
  $users                = undef,
  $users_hiera_merge    = false,
  $ssh_keys             = undef,
  $ssh_keys_hiera_merge = false,
){

  if is_string($users_hiera_merge) {
    $users_hiera_merge_real = str2bool($users_hiera_merge)
  } else {
    $users_hiera_merge_real = $users_hiera_merge
  }
  validate_bool($users_hiera_merge_real)

  if is_string($ssh_keys_hiera_merge) {
    $ssh_keys_hiera_merge_real = str2bool($ssh_keys_hiera_merge)
  } else {
    $ssh_keys_hiera_merge_real = $ssh_keys_hiera_merge
  }
  validate_bool($ssh_keys_hiera_merge_real)

  if $ssh_keys != undef {

    if $ssh_keys_hiera_merge_real == true {
      $ssh_keys_real = hiera_hash('vas_local_user::ssh_keys')
    } else {
      $ssh_keys_real = $ssh_keys
    }
  }

  if is_hash($users) {

    if $users_hiera_merge_real == true {
      $users_real = hiera_hash('vas_local_user::users')
    } else {
      $users_real = $users
    }

    validate_hash($users_real)

    $defaults = {
      'managehome' => true,
    }
    $vasdefaults = merge($defaults, {
      'forcelocal'  => true,
      'before'      => Class['vas'],
    })

    if defined(Class['vas']) { # VAS managed
      if $::vas_version { # VAS installed
        # Do nothing right now
      } else { # VAS not installed yet
        create_resources(user, $users_real, $vasdefaults)
        $user_managed = true
      }
    } elsif $::vas_version { # Vas NOT managed but installed
      # Do nothing right now
    } else { # VAS NOT managed nor installed
      create_resources(user, $users_real, $defaults)
      $user_managed = true
    }

    if $user_managed == true and is_hash($ssh_keys_real) {
      create_resources(ssh_authorized_key, $ssh_keys_real)
    }

  }

}
