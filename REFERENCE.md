# Reference

<!-- DO NOT EDIT: This document was generated by Puppet Strings -->

## Table of Contents

### Classes

#### Public Classes

* [`yum_cron`](#yum_cron): Manage yum-cron

#### Private Classes

* `yum_cron::config`: Manage yum-cron configs
* `yum_cron::install`: Install yum-cron
* `yum_cron::service`: Manage yum-cron service

### Resource types

* [`dnf_automatic_config`](#dnf_automatic_config): Section/setting name to manage from dnf-automatic.conf
* [`yum_cron_config`](#yum_cron_config): Section/setting name to manage from yum-cron.conf
* [`yum_cron_hourly_config`](#yum_cron_hourly_config): Section/setting name to manage from yum-cron-hourly.conf

### Data types

* [`Yum_cron::Update_cmd`](#yum_cronupdate_cmd): yum-cron update cmd

## Classes

### <a name="yum_cron"></a>`yum_cron`

Manage yum-cron

#### Parameters

The following parameters are available in the `yum_cron` class:

* [`ensure`](#ensure)
* [`enable`](#enable)
* [`download_updates`](#download_updates)
* [`apply_updates`](#apply_updates)
* [`upgrade_type`](#upgrade_type)
* [`debug_level`](#debug_level)
* [`exclude_packages`](#exclude_packages)
* [`randomwait`](#randomwait)
* [`mailto`](#mailto)
* [`systemname`](#systemname)
* [`email_host`](#email_host)
* [`update_cmd`](#update_cmd)
* [`update_messages`](#update_messages)
* [`extra_configs`](#extra_configs)
* [`extra_hourly_configs`](#extra_hourly_configs)
* [`yum_autoupdate_ensure`](#yum_autoupdate_ensure)
* [`package_ensure`](#package_ensure)
* [`package_name`](#package_name)
* [`service_name`](#service_name)
* [`service_ensure`](#service_ensure)
* [`service_enable`](#service_enable)
* [`service_hasstatus`](#service_hasstatus)
* [`service_hasrestart`](#service_hasrestart)
* [`config_path`](#config_path)

##### <a name="ensure"></a>`ensure`

Data type: `Enum['present', 'absent']`

Defines the presence of `yum-cron`.

Default value: `'present'`

##### <a name="enable"></a>`enable`

Data type: `Boolean`

Boolean that defines the state of `yum-cron`.

Default value: ``true``

##### <a name="download_updates"></a>`download_updates`

Data type: `Boolean`

Boolean that determines if updates should be automatically downloaded.

Default value: ``true``

##### <a name="apply_updates"></a>`apply_updates`

Data type: `Boolean`

Boolean that determines if updates should be automatically installed.
If set to `true` then `download_updates` ignored.

Default value: ``false``

##### <a name="upgrade_type"></a>`upgrade_type`

Data type: `Enum['default','security']`

The kind of updates to perform.
Applies only to EL8.

Default value: `'default'`

##### <a name="debug_level"></a>`debug_level`

Data type: `Pattern[/^(?:-)?[0-9]$/]`

Sets debug level.
Applies only to EL7 and EL8.

Default value: `'-2'`

##### <a name="exclude_packages"></a>`exclude_packages`

Data type: `Array`

Packages to exclude from updates.
Applies only to EL7 and EL8.

Default value: `[]`

##### <a name="randomwait"></a>`randomwait`

Data type: `Pattern[/^[0-9]+$/]`

Sets random wait time.
Applies only to EL7 and EL8.

Default value: `'360'`

##### <a name="mailto"></a>`mailto`

Data type: `String`

Address notified about updates.
Applies only to EL7 and EL8.

Default value: `'root'`

##### <a name="systemname"></a>`systemname`

Data type: `String`

Name of system used in notifications.
Applies only to EL7 and EL8.

Default value: `$::fqdn`

##### <a name="email_host"></a>`email_host`

Data type: `String`

Host used to send email messages.
Applies only to EL7 and EL8.

Default value: `'localhost'`

##### <a name="update_cmd"></a>`update_cmd`

Data type: `Yum_cron::Update_cmd`

The kind of updates to use.
Applies only to EL7.
Valid values:
* default                            = yum upgrade
* security                           = yum --security upgrade
* security-severity:Critical         = yum --sec-severity=Critical upgrade
* minimal                            = yum --bugfix upgrade-minimal
* minimal-security                   = yum --security upgrade-minimal
* minimal-security-severity:Critical =  --sec-severity=Critical upgrade-minimal

Default value: `'default'`

##### <a name="update_messages"></a>`update_messages`

Data type: `Enum['yes','no']`

Determines whether a message should be emitted when updates are available, downloaded, and applied.
Applies only to EL7.

Default value: `'yes'`

##### <a name="extra_configs"></a>`extra_configs`

Data type: `Hash`

Hash that can be used to define additional configurations.
Applies only to EL7 and EL8.

For EL8 the hash defines additonal `dnf_automatic_config` resources.
For EL7 the hash defines additional `yum_cron_config` resources.

Default value: `{}`

##### <a name="extra_hourly_configs"></a>`extra_hourly_configs`

Data type: `Hash`

Hash that can be used to define additional hourly configurations.
Applies only to EL7.

For EL7 the hash defines additional `yum_cron_hourly_config` resources.

Default value: `{}`

##### <a name="yum_autoupdate_ensure"></a>`yum_autoupdate_ensure`

Data type: `Enum['undef', 'UNSET', 'absent', 'disabled']`

Defines how to handle yum-autoupdate on Scientific Linux systems.
Applies only to Scientific Linux.
Valid values:
* 'disabled' (default) - Sets ENABLED='false' in /etc/sysconfig/yum-autoupdate.
* 'absent' - Uninstall the yum-autoupdate package.
* 'undef' or 'UNSET' - Leave yum-autoupdate unmanaged.

Default value: `'disabled'`

##### <a name="package_ensure"></a>`package_ensure`

Data type: `Optional[String]`

The ensure value passed to yum-cron package resource.
When `undef`, the value passed to the package resources is based on this class' `ensure` parameter value.

Default value: ``undef``

##### <a name="package_name"></a>`package_name`

Data type: `String`

yum-cron package name.  Default is based on OS version.

##### <a name="service_name"></a>`service_name`

Data type: `String`

yum-cron service name.  Default is based on OS version.

##### <a name="service_ensure"></a>`service_ensure`

Data type: `Optional[String]`

The ensure value passed to yum-cron service resource.
When `undef`, the value passed to the service resources is based on this class' `ensure` and `enable` parameter values.

Default value: ``undef``

##### <a name="service_enable"></a>`service_enable`

Data type: `Optional[Boolean]`

The ensure value passed to yum-cron package resource.
When `undef`, the value passed to the service resources is based on this class' `ensure` and `enable` parameter values.

Default value: ``undef``

##### <a name="service_hasstatus"></a>`service_hasstatus`

Data type: `Boolean`

Service hasstatus property.

Default value: ``true``

##### <a name="service_hasrestart"></a>`service_hasrestart`

Data type: `Boolean`

Service hasrestart property.

Default value: ``true``

##### <a name="config_path"></a>`config_path`

Data type: `Stdlib::Absolutepath`

Path to yum-cron configuration.  Default is based on OS version.

## Resource types

### <a name="dnf_automatic_config"></a>`dnf_automatic_config`

Section/setting name to manage from dnf-automatic.conf

#### Properties

The following properties are available in the `dnf_automatic_config` type.

##### `ensure`

Valid values: `present`, `absent`

The basic property that the resource should be in.

Default value: `present`

##### `value`

The value of the setting to be defined.

#### Parameters

The following parameters are available in the `dnf_automatic_config` type.

* [`name`](#name)
* [`provider`](#provider)

##### <a name="name"></a>`name`

namevar

Section/setting name to manage from dnf-automatic.conf

##### <a name="provider"></a>`provider`

The specific backend to use for this `dnf_automatic_config` resource. You will seldom need to specify this --- Puppet
will usually discover the appropriate provider for your platform.

### <a name="yum_cron_config"></a>`yum_cron_config`

Section/setting name to manage from yum-cron.conf

#### Properties

The following properties are available in the `yum_cron_config` type.

##### `ensure`

Valid values: `present`, `absent`

The basic property that the resource should be in.

Default value: `present`

##### `value`

The value of the setting to be defined.

#### Parameters

The following parameters are available in the `yum_cron_config` type.

* [`name`](#name)
* [`provider`](#provider)

##### <a name="name"></a>`name`

namevar

Section/setting name to manage from yum-cron.conf

##### <a name="provider"></a>`provider`

The specific backend to use for this `yum_cron_config` resource. You will seldom need to specify this --- Puppet will
usually discover the appropriate provider for your platform.

### <a name="yum_cron_hourly_config"></a>`yum_cron_hourly_config`

Section/setting name to manage from yum-cron-hourly.conf

#### Properties

The following properties are available in the `yum_cron_hourly_config` type.

##### `ensure`

Valid values: `present`, `absent`

The basic property that the resource should be in.

Default value: `present`

##### `value`

The value of the setting to be defined.

#### Parameters

The following parameters are available in the `yum_cron_hourly_config` type.

* [`name`](#name)
* [`provider`](#provider)

##### <a name="name"></a>`name`

namevar

Section/setting name to manage from yum-cron-hourly.conf

##### <a name="provider"></a>`provider`

The specific backend to use for this `yum_cron_hourly_config` resource. You will seldom need to specify this --- Puppet
will usually discover the appropriate provider for your platform.

## Data types

### <a name="yum_cronupdate_cmd"></a>`Yum_cron::Update_cmd`

yum-cron update cmd

Alias of

```puppet
Enum['default', 'security', 'security-severity:Critical', 'minimal', 'minimal-security', 'minimal-security-severity:Critical']
```
