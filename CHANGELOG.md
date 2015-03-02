## treydock-yum_cron changelog

Release notes for the treydock-yum_cron module.

------------------------------------------

#### 1.2.0 - 2015-03-02

Changes:

* Add parameter `config_template` that defines which template to use for configuring yum-cron
* Add basic EL7 support

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
