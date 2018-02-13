# puppet-yum_cron

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/yum_cron.svg)](https://forge.puppetlabs.com/treydock/yum_cron)
[![Build Status](https://travis-ci.org/treydock/puppet-yum_cron.svg?branch=master)](https://travis-ci.org/treydock/puppet-yum_cron)

#### Table of Contents

1. [Overview - What is the yum_cron module?](#overview)
2. [Backwards Compatibility - Key changes between versions](#backwards-compatibility)
2. [Usage - Configuration and customization options](#usage)
3. [Reference - Parameter and detailed reference to all options](#reference)
    * [Public Classes](#public-classes)
4. [Compatibility - Operating system and Puppet compatibility](#compatibility)
5. [Development - Guide for contributing to the module](#development)
    * [Testing - Testing your configuration](#testing)

## Overview

The yum_cron module manages the *yum-cron* package to allow for automatic updates and available updates notifications.

## Backwards Compatibility

Version 3.x of this module modified the way `apply_updates` and `download_updates` parameters are handled.  `apply_updates` now takes precedence over `download_updates`.  If `apply_updates` is `true` then `download_updates` has no effect.


Version 2.x of this module added and removed many parameters.  See [CHANGELOG](CHANGELOG.md) for detailed list of all the changes.


Version 1.x of this module replaced the **disable_yum_autoupdate** and **remove_yum_autoupdate** parameters with **yum_autoupdate_ensure**.  The default behavior is still to disable yum-autoupdate.

## Usage

### Class: yum_cron

The default parameters will install and enable yum-cron to only check for updates and notify root if any are available.

**On Scientific Linux the default behavior is also to disable *yum-autoupdate*.**

    class { 'yum_cron': }

These are the actions taken by the module with default parameter values:

* Install yum-cron
* Set configuration values to enable checking for updates and notify root
* Start and enable the yum-cron service
* Disable yum-autoupdate by setting ENABLED="false" in /etc/sysconfig/yum-autoupdate **(Scientific Linux only)**

This is an example of enabling automatic updates

    class { 'yum_cron':
      apply_updates => true,
    }

Refer to the yum-cron manpage for all available configuration options.

Additional configuration values can be passed to the `yum-cron` configurations via the `extra_configs` parameter.

To define additional configuration options for EL6:

    class { 'yum_cron':
      extra_configs => {
        'yum_cron ERROR_LEVEL' => { 'variable' => 'ERROR_LEVEL', 'value' => '1' }
      }
    }

To define additional configuration options for EL7:

    class { 'yum_cron':
      extra_configs => {
        'email/email_from' => { 'value' => 'foo@bar.com' }
      }
    }

## Reference

* [Public Classes](#public-classes)
  * [Class: yum_cron](#class-yum_cron)

### Public Classes

#### Class: `yum_cron`:

Installs and configures yum-cron.  Default values in Hiera format are below.

$::osfamily == 'RedHat'

    yum_cron::ensure: 'present'
    yum_cron::enable: true
    yum_cron::download_updates: true
    yum_cron::apply_updates: false
    yum_cron::mailto: 'root'
    yum_cron::systemname: "%{::fqdn}"
    yum_cron::days_of_week: '0123456'
    yum_cron::cleanday: '0'
    yum_cron::update_cmd: 'default'
    yum_cron::update_message: 'yes'
    yum_cron::email_host: 'localhost'
    yum_cron::extra_configs: {}
    yum_cron::yum_autoupdate_ensure: 'disabled'
    yum_cron::package_ensure: undef
    yum_cron::package_name: 'yum-cron'
    yum_cron::service_name: 'yum-cron'
    yum_cron::service_ensure: undef
    yum_cron::service_enable: undef
    yum_cron::service_hasstatus: true
    yum_cron::service_hasrestart: true

$::operatingsystemmajrelease == '7'

    yum_cron::debug_level: '-2'
    yum_cron::randomwait: '360'
    yum_cron::config_path: '/etc/yum/yum-cron.conf'

$::operatingsystemmajrelease == '6'

    yum_cron::debug_level: '0'
    yum_cron::randomwait: '60'
    yum_cron::config_path: '/etc/sysconfig/yum-cron'

##### `ensure`

Defines the presence of `yum-cron`.  Valid values are 'present' and 'absent'.  Default is `'present'`.

##### `enable`

Boolean that defines the state of `yum-cron`.  Default is `true`

##### `download_updates`

Boolean that determines if updates should be automatically downloaded.  Default is `true`

##### `apply_updates`

Boolean that determines if updates should be automatically installed.  Default is `false`.  If set to `true` then `download_updates` ignored.

##### `debug_level`

Sets debug level.  Default varies based on OS version
Applies only to EL7 and EL6.

##### `randomwait`

Sets random wait time.  Default varies based on OS version
Applies only to EL7 and EL6.

##### `mailto`

Address notified about updates.  Default is 'root'
Applies only to EL7 and EL6.

##### `systemname`

Name of system used in notifications.  Default is `$::fqdn`
Applies only to EL7 and EL6.

##### `days_of_week`

Days of the week that yum-cron will run.  Default is `'0123456'`
Applies only to EL6.

##### `cleanday`

Day of the week yum-cron will cleanup.  Default is '0'
Applies only to EL6.

##### `update_cmd`

The kind of updates to use.  Default is 'default'
Applies only to EL7.

Valid values:

    # default                            = yum upgrade
    # security                           = yum --security upgrade
    # security-severity:Critical         = yum --sec-severity=Critical upgrade
    # minimal                            = yum --bugfix upgrade-minimal
    # minimal-security                   = yum --security upgrade-minimal
    # minimal-security-severity:Critical =  --sec-severity=Critical upgrade-minimal

##### `update_messages`

Determines whether a message should be emitted when updates are available, downloaded, and applied.  Default is 'yes'
Applies only to EL7.

##### `email_host`

Host used to send email messages.  Default is 'localhost'
Applies only to EL7.

##### `extra_configs`

Hash that can be used to define additional configurations.  Default is {}
Applies only to EL7 and EL6.

The Hash is passed to `create_resources`.
For EL7 the hash defines additional `yum_cron_config` resources.
For EL6 the hash defines additional `shellvar` resources.

##### `yum_autoupdate_ensure`

Defines how to handle yum-autoupdate on Scientific Linux systems.  Default is 'disabled'
Applies only to Scientific Linux.

Valid values:

* 'disabled' (default) - Sets ENABLED='false' in /etc/sysconfig/yum-autoupdate.
* 'absent' - Uninstall the yum-autoupdate package.
* 'undef' or 'UNSET' - Leave yum-autoupdate unmanaged.

##### `package_ensure`

The ensure value passed to yum-cron package resource.  Default is `undef`
When `undef`, the value passed to the package resources is based on this class' `ensure` parameter value.

##### `package_name`

yum-cron package name.  Default is `'yum-cron'`

##### `service_name`

yum-cron service name.  Default is `'yum-cron'`

##### `service_ensure`

The ensure value passed to yum-cron service resource.  Default is `undef`
When `undef`, the value passed to the service resources is based on this class' `ensure` and `enable` parameter values.

##### `service_enable`

The ensure value passed to yum-cron package resource.  Default is `undef`
When `undef`, the value passed to the service resources is based on this class' `ensure` and `enable` parameter values.

##### `service_hasstatus`

Service hasstatus property.  Default is `true`

##### `service_hasrestart`

Service hasrestart property.  Default is `true`

##### `config_path`

Path to yum-cron configuration.  Default is based on OS version.

## Compatibility

This module should be compatible with all RedHat based operating systems and Puppet 4.7.x and later.

It has only been tested on:

* CentOS 7
* CentOS 6
* Scientific Linux 6

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake test

If you have Vagrant >= 1.2.0 installed you can run system tests

    bundle exec rake beaker

## TODO

*
