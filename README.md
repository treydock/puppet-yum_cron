# puppet-yum_cron

[![Build Status](https://travis-ci.org/treydock/puppet-yum_cron.png)](https://travis-ci.org/treydock/puppet-yum_cron)

####Table of Contents

1. [Overview - What is the yum_cron module?](#overview)
2. [Backwards Compatibility - Key changes between versions](#backwards-compatibility)
2. [Usage - Configuration and customization options](#usage)
    * [Class: yum_cron](#class-yum_cron)
3. [Compatibility - Operating system and Puppet compatibility](#compatibility)
4. [Development - Guide for contributing to the module](#development)
    * [Testing - Testing your configuration](#testing)

## Overview

The yum_cron module manages the *yum-cron* package to allow for automatic updates and available updates notifications.

## Backwards Compatibility

Version 1.x of this module replaced the **disable_yum_autoupdate** and **remove_yum_autoupdate** parameters with **yum_autoupdate_ensure**.  The default behavior is still to disable yum-autoupdate.

## Usage

### Class: yum_cron

The default parameters will install and enable yum-cron to only check for updates and notify root if any are available.

**On Scientific Linux the default behavior is to disable *yum-autoupdate*.**

    class { 'yum_cron': }

These are the actions take by the module with default parameter values:

* Install yum-cron
* Set configuration values in /etc/sysconfig/yum-cron
  * CHECK_ONLY=yes
  * MAILTO=root **(EL6 only)**
* Start and enable the yum-cron service
* Disable yum-autoupdate by setting ENABLED="false" in /etc/sysconfig/yum-autoupdate **(Scientific Linux only)**

This is an example of enabling automatic updates

    class { 'yum_cron':
      check_only => 'no',
    }

Refer to the yum-cron manpage for all available configuration options.

The following are valid values for **yum_autoupdate_ensure**:

* disabled (default) - Sets ENABLED='false' in /etc/sysconfig/yum-autoupdate.
* absent - Uninstall the yum-autoupdate package.
* undef or UNSET - Leave yum-autoupdate unmanaged.

## Compatibility

This module should be compatible with all RedHat based operating systems and Puppet 2.7.x and later.

It has only been tested on:

* CentOS 6
* CentOS 5
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
