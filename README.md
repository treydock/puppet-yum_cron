# puppet-yum_cron

[![Build Status](https://travis-ci.org/treydock/puppet-yum_cron.png)](https://travis-ci.org/treydock/puppet-yum_cron)

## Overview

## Support

Tested using
* CentOS 6.4

## Reference

### Class: yum_cron

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

## TODO

* Remove or disable yum-autoupdate installed by default in SL 6
