# echoes-alert

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with wt](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with echoes_alert](#beginning-with-echoes_alert)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Contributors](#contributors)

## Overview

Puppet module to manage Echoes Alert installation and configuration.

## Module Description

This module installs and configures Echoes Alert.

## Setup

### Setup requirements

ToDo

### Beginning with echoes_alert

```puppet
include 'echoes_alert'
```

## Usage

An example of resource-like class declaration: 

```puppet
class {'echoes_alert':
  branch  => 'develop',
  version => 'latest',
}
```
## Reference

### Classes

#### Public classes

* echoes_alert: Main class, includes all other classes.

#### Private classes

* echoes_alert::params: Sets parameter defaults.
* echoes_alert::install: Handles the binary.
* echoes_alert::config: Handles the configuration.
* echoes_alert::service: Handles the service.

#### Parameters

The following parameters are available in the `::echoes_alert` class:

##### `branch`

Tells Puppet which branch to choose to install. Valid options: string. Default value: 'master'

##### `manage_firewall`

If true and if puppetlabs-firewall module is present, Puppet manages firewall to allow HTTP access for Echoes Alert. Valid options: 'true' or 'false'. Default value: 'false'

##### `version`

Tells Puppet which version to choose to install. Valid options: 'latest' or a specific version number. Default value: 'latest'

## Limitations

Debian family OSes is officially supported. Tested and built on Debian.

##Development

[Echoes Technologies](https://www.echoes-tech.com) modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great.

## Contributors

The list of contributors can be found at: https://forge.echoes-tech.com/projects/puppet-echoes_alert/repository/statistics#statistics-contributors
