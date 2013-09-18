# puppet-yum_cron

[![Build Status](https://travis-ci.org/treydock/puppet-yum_cron.png)](https://travis-ci.org/treydock/puppet-yum_cron)

####Table of Contents

1. [Overview - What is the yum_cron module?](#overview)
2. [Usage - Configuration and customization options](#usage)
    * [Class: yum_cron](#class-yum_cron)
3. [Compatibility - Operating system and Puppet compatibility](#compatibility)
4. [Development - Guide for contributing to the module](#development)
    * [Testing - Testing your configuration](#testing)

## Overview

The yum_cron module manages the *yum-cron* package to allow for automatic updates and available updates notifications.

## Usage

### Class: yum_cron

The default parameters will install and enable yum-cron to only check for updates and notify root if any are available.

**On Scientific Linux the default behavior is to also disable *yum-autoupdate*.**  This can be changed with the *disable_yum_autoupdate* parameter.  The yum-autoupdate package can be removed by setting the *remove_yum_autoupdate* parameter to true.

    class { 'yum_cron': }

These are the actions take by the module with default parameter values:

* Install yum-cron
* Set configuration values in /etc/sysconfig/yum-cron
  * CHECK_ONLY=yes
  * MAILTO=root
* Start and enable the yum-cron service
* Disable yum-autoupdate **(Scientific Linux only)**
  * Sets ENABLED=false in /etc/sysconfig/yum-autoupdate

This is an example of enabling automatic updates

    class { 'yum_cron':
      check_only => 'no',
    }

Refer to the yum-cron manpage for all available configuration options.

## Compatibility

This module should be compatible with all RedHat based operating systems and Puppet 2.6.x and later.

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake ci

If you have Vagrant >= 1.2.0 installed you can run system tests

    bundle exec rake spec:system
