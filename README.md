# puppet-yum_cron

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/yum_cron.svg)](https://forge.puppetlabs.com/treydock/yum_cron)
[![Build Status](https://travis-ci.org/treydock/puppet-yum_cron.svg?branch=master)](https://travis-ci.org/treydock/puppet-yum_cron)

#### Table of Contents

1. [Overview - What is the yum_cron module?](#overview)
2. [Backwards Compatibility - Key changes between versions](#backwards-compatibility)
2. [Usage - Configuration and customization options](#usage)
3. [Reference - Parameter and detailed reference to all options](#reference)
4. [Compatibility - Operating system and Puppet compatibility](#compatibility)
5. [Development - Guide for contributing to the module](#development)
    * [Testing - Testing your configuration](#testing)

## Overview

The yum_cron module manages either the *yum-cron* or *dnf-automatic* (RHEL/CentOS 8+) package to allow for automatic updates
and available updates notifications.

## Backwards Compatibility

Version 3.x of this module modified the way `apply_updates` and `download_updates` parameters are handled.  `apply_updates` now takes precedence over `download_updates`.  If `apply_updates` is `true` then `download_updates` has no effect.


Version 2.x of this module added and removed many parameters.  See [CHANGELOG](CHANGELOG.md) for detailed list of all the changes.


Version 1.x of this module replaced the **disable_yum_autoupdate** and **remove_yum_autoupdate** parameters with **yum_autoupdate_ensure**.  The default behavior is still to disable yum-autoupdate.

## Usage

### Class: yum_cron

The default parameters will install and enable yum-cron to only check for updates and notify root if any are available.
Generally, dnf-automatic uses different paths, but functions very similarly and has a similar config file.  For the rest
of the documentation, you can generally assuming that references to yum-cron also apply to dnf-automatic.

**On Scientific Linux the default behavior is also to disable *yum-autoupdate*.**

    class { 'yum_cron': }

These are the actions taken by the module with default parameter values:

* Install yum-cron/dnf-automatic
* Set configuration values to enable checking for updates and notify root
* Start and enable the yum-cron/dnf-automatic service
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

[http://treydock.github.io/puppet-yum_cron/](http://treydock.github.io/puppet-yum_cron/)

## Compatibility

This module should be compatible with all RedHat based operating systems and Puppet 4.7.x and later.

It has only been tested on:

* RHEL/CentOS 8
* RHEL/CentOS 7
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
