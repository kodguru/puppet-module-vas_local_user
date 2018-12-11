# vas_local_user

[![Build Status](https://api.travis-ci.org/gillarkod/puppet-module-vas_local_user.png)](https://travis-ci.org/gillarkod/puppet-module-vas_local_user)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with vas_local_user](#setup)
    * [What vas_local_user affects](#what-vas_local_user-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with vas_local_user](#beginning-with-vas_local_user)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module allows you to manage both users and ssh_authorized_keys on systems
using QAS/VAS. The thought behind it is make it easier for you to create users
on systems with and without QAS installed.

## Module Description

This module manages one or more local users and ssh_authorized_keys (if configured).
If it's a newly provisioned system it will create the user or users before installing
QAS. If QAS is already installed on the system it will only manage the user
and its ssh_authorized_keys if libuser is supported. The user will be managed on
systems without QAS too.

## Setup

### What vas_local_user affects

* It affects the users and ssh_authorized_keys it's configured to manage.

### Beginning with vas_local_user

If the module is included in the catalogue but not configured in any way it
does not do anything. It takes in total four different parameters.

The following defaults are used when creating a user.

Not using QAS:
  'manage_home' => true
  'forcelocal'  => true

Using QAS (settings above and...):
  'before'      => Class['vas']

## Usage

### manage_users

Boolean to control if this module should manage users or not.

- *Default*: true

### users

A hash of all users the module should manage/create.

- *Default*: undef

### ssh_keys

A hash of all ssh_authorized_keys the module should manage/create.

- *Default*: undef

### users_hiera_merge

Set to true to enable hiera_merge for parameter 'users'.

- *Default*: false

### groups_hiera_merge

Set to true to enable hiera_merge for parameter 'groups'.

- *Default*: false

## Reference

Classes:

* vas_local_user

## Limitations

This module uses before on Class['vas'] to guess whether QAS is in the catalogue
or not. This module has been tested in combination with Ericsson/puppet-module-vas.

Requires Puppet >=3.2 since it uses User type's parameter forcelocal.

## Development

Please make changes atomic. Rebase your commits if neccessary to make it atomic.
