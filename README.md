# puppet-yum_cron

[![Build Status](https://travis-ci.org/treydock/puppet-yum_cron.png)](https://travis-ci.org/treydock/puppet-yum_cron)

## Overview

The yum_cron module manages the *yum-cron* package to allow for automatic updates and available updates notifications.

## Reference

### Class: yum_cron

The default parameters will install and enable yum-cron to only check for updates and notify root if any are available.

**On Scientific Linux the default behavior is to also disable *yum-autoupdate*.**  This can be changed with the *disable_yum_autoupdate* parameter.

    class { 'yum_cron': }

These are the actions take by the module with default parameter values:

* Install yum-cron
* Enable the yum-cron service
* Set configuration values in /etc/sysconfig/yum-cron
  * CHECK_ONLY=yes
  * MAILTO=root
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
