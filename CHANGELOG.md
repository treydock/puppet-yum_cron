## treydock-yum_cron changelog

Release notes for the treydock-yum_cron module.

------------------------------------------

#### 4.0.0 - 2018-02-12

This release modernizes this module.

##### Backwards incompatible changes

* Remove support for EL5
* Drop support for Puppet 3.x.  Require Puppet >= 4.7.0

------------------------------------------

#### 3.0.0 - 2018-02-10

This releases addresses a bug that prevented automatic updates from working the same between EL6 and EL7 systems.  Because the module's handling of parameters is changed, this is being released as a non-backwards compatible release.

##### Backwards incompatible changes

* `apply_updates` now takes precedence over `download_updates`.  If `apply_updates` is `true` then `download_updates` has no effect.

------------------------------------------

#### 2.0.0 - 2015-11-12

This release introduces many backwards incompatible changes.  The goal of this release is to make the module's behavior consistent across EL5, EL6 and EL7 despite yum-cron being drastically different across those platforms.

##### Backwards incompatible changes

* Remove the following parameters
    * `yum_parameter`
    * `check_first`
    * `error_level`
    * `service_waits`
    * `service_wait_time`
    * `service_autorestart`
    * `config_template`
* Removed `check_only` parameter.  The value configured is now based on `apply_updates` value
* Removed `download_only` and `download_updates` parameters.  The values configured are now based on `download_updates` value
* Change default value for `service_ensure` and `service_enable` to `undef`.  The default behavior remains the same if `enable` is `true` and `ensure` is `present`

##### Features

* Add parameter `ensure` that manages the presence of yum-cron
* Add parameter `enable` that manages the state of yum-cron
* Add parameter `download_updates` that determines if updates should be downloaded
* Add parameter `apply_updates` that determines if updates should be applied
* Add parameter `package_ensure`
* Add custom type/provider to manage config values on EL7 systems
* Use shellvar type to manage config values on EL6 and EL5
* Add parameter `extra_configs` which can be used to define additional configuration values not directly set by other parameters
* Add dependency `puppetlabs/inifile`: Used by `yum_cron_config` type to manage EL7 configuration values
* Add dependency `herculesteam/augeasproviders_shellvar`: Used to manage EL5 and EL6 configuration values

------------------------------------------

#### 1.3.0 - 2015-10-02

This release adds new features to this module focused on better support for EL7.

Changes:

* Added parameters that only apply to EL7
    * update_cmd
    * update_messages
    * download_updates
    * email_host
* The following parameters now effect EL7 configurations
    * debug_level
    * randomwait
* Updates to unit testing dependencies and Travis-CI test matrixes
* Update acceptance tests to validate EL7
* Update nodesets used for acceptance tests including docker nodesets

------------------------------------------

#### 1.2.0 - 2015-03-02

Changes:

* Add parameter `config_template` that defines which template to use for configuring yum-cron
* Add basic EL7 support
* Move system test gem dependencies to a separate group excluded during travis-ci tests

------------------------------------------

#### 1.1.1 - 2014-11-07

Changes:

* Update beaker tests to not depend on augeasproviders

------------------------------------------

#### 1.1.0 - 2014-11-03

Features:

* Remove dependency on augeasproviders and use file_line to disable yum-autoupdates
* Add support for EL5
* Replace rspec-system tests with beaker acceptance tests
* Update unit testing dependencies

------------------------------------------

#### 1.0.0 - 2013-12-12

Backwards incompatible changes:

* Replace disable\_yum\_autoupdate and remove\_yum\_autoupdate parameters with yum\_autoupdate\_ensure

Minor changes:

* Bring regression testing up-to-date
* Remove Puppet-2.6 from travis-ci tests

------------------------------------------

#### 0.1.0 - 2013-09-18

* Replace augeas with shellvar provider for disabling yum-autoupdate 
* Add remove\_yum\_autoupdate parameter to uninstall yum-autoupdate

------------------------------------------

#### 0.0.1 - 2013-09-04

* Initial release
