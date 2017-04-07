# == Class: vas_local_user
#
class vas_local_user(
  $manage_users         = true,
  $users                = undef,
  $users_hiera_merge    = false,
  $ssh_keys             = undef,
  $ssh_keys_hiera_merge = false,
){

  if is_string($manage_users) {
    $manage_users_real = str2bool($manage_users)
  } else {
    $manage_users_real = $manage_users
  }
  validate_bool($manage_users_real)

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
  else {
    $ssh_keys_real = undef
  }

  if $manage_users_real and is_hash($users) {

    if $users_hiera_merge_real == true {
      $users_real = hiera_hash('vas_local_user::users')
    } else {
      $users_real = $users
    }

    validate_hash($users_real)

    $defaults = {
      'managehome'  => true,
      'forcelocal'  => true,
    }

    $vasdefaults = merge($defaults, {
      'before'      => Class['vas'],
    })


    if defined(Class['vas']) {
      $vas_managed = true
    } else {
      $vas_managed = false
    }

    if $::vas_version {
      $vas_installed = true
    } else {
      $vas_installed = false
    }

    if $::vas_local_user_libuser == 'yes' {
      $libuser_support = true
    } else {
      $libuser_support = false
    }

    # VAS managed and installed with libuser support
    if $vas_managed and $vas_installed and $libuser_support {
      create_resources(user, $users_real, $vasdefaults)
      $user_managed = true
    }
    # VAS managed but not (yet) installed
    elsif $vas_managed and ! $vas_installed {
      create_resources(user, $users_real, $vasdefaults)
      $user_managed = true
    }
    # VAS not managed but installed with libuser support
    elsif ! $vas_managed and $vas_installed and $libuser_support {
      create_resources(user, $users_real, $defaults)
      $user_managed = true
    }
    # VAS neither managed or installed
    elsif ! $vas_managed and ! $vas_installed {
      create_resources(user, $users_real, $defaults)
      $user_managed = true
    }
    else {
      $user_managed = false
    }

    if $user_managed == true and is_hash($ssh_keys_real) {
      create_resources(ssh_authorized_key, $ssh_keys_real)
    }
  }
}
