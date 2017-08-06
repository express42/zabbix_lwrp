[![Chef cookbook](https://img.shields.io/cookbook/v/zabbix_lwrp.svg)](https://github.com/express42/zabbix_lwrp)

[![Code Climate](https://codeclimate.com/github/express42/zabbix_lwrp/badges/gpa.svg)](https://codeclimate.com/github/express42/zabbix_lwrp)
[![Build Status](https://travis-ci.org/express42/zabbix_lwrp.svg?branch=master)](https://travis-ci.org/express42/zabbix_lwrp)

# Description

[![Join the chat at https://gitter.im/express42/zabbix_lwrp](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/express42/zabbix_lwrp?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Installs and configures Zabbix agent and server with PostgreSQL/MySQL and Nginx. Provides LWRP for creating and modifying Zabbix objects.

# Requirements

## Platform:

* ubuntu
* centos
* windows

## Cookbooks:

* apt
* build-essential
* chef_nginx
* chocolatey
* database
* lvm
* php-fpm
* postgresql
* mysql2_chef_gem
* mysql
* yum-mysql-community
* mysql2_chef_gem
* windows_firewall

# Attributes

## Agent
* `node['zabbix']['agent']['windows']['installer']` - 'chocolatey' or 'bin'(zabbix binaries). Defaults to `chocolatey`.
* `node['zabbix']['agent']['windows']['version']` -  Defaults to `3.2.0`.
* `node['zabbix']['agent']['windows']['chocolatey']['repo']` -  Defaults to `https://chocolatey.org/api/v2`.
* `node['zabbix']['agent']['windows']['path']` -  Defaults to `C:\ProgramData\zabbix`.
* `node['zabbix']['agent']['scripts']` -  Defaults to `case node['platform']`.
* `node['zabbix']['agent']['include']` -  Defaults to `case node['platform']`.
* `node['zabbix']['agent']['config']['listen_ip']` -  Defaults to `0.0.0.0`.
* `node['zabbix']['agent']['config']['listen_port']` -  Defaults to `10050`.
* `node['zabbix']['agent']['config']['serverhost']` -  Defaults to `localhost`.
* `node['zabbix']['agent']['config']['hostname']` -  Defaults to `node['fqdn']`.
* `node['zabbix']['agent']['config']['pidfile']` -  Defaults to `/var/run/zabbix/zabbix_agentd.pid`.
* `node['zabbix']['agent']['config']['logs']` -  Defaults to `{ ... }`.
* `node['zabbix']['agent']['config']['global']` -  Defaults to `{ ... }`.
* `node['zabbix']['agent']['config']['user_params']` -  Defaults to `{ ... }`.

## Postgresql
* `node['zabbix']['version']` -  Defaults to `3.2`.
* `node['zabbix']['api-version']` -  Defaults to `3.1.0`.
* `node['zabbix']['host']['group']` -  Defaults to `Hosts`.
* `node['zabbix']['host']['name']` -  Defaults to `node['fqdn']`.
* `node['zabbix']['host']['dns']` -  Defaults to `node['fqdn']`.
* `node['zabbix']['host']['ipaddress']` -  Defaults to `node['ipaddress']`.
* `node['zabbix']['host']['ipmi']['enabled']` -  Defaults to `false`.
* `node['zabbix']['host']['ipmi']['port']` -  Defaults to `623`.
* `node['zabbix']['host']['ipmi']['use_ip']` -  Defaults to `true`.
* `node['zabbix']['host']['jmx']['enabled']` -  Defaults to `false`.
* `node['zabbix']['host']['jmx']['port']` -  Defaults to `12345`.
* `node['zabbix']['host']['jmx']['use_ip']` -  Defaults to `true`.
* `node['zabbix']['host']['snmp']['enabled']` -  Defaults to `false`.
* `node['zabbix']['host']['snmp']['port']` -  Defaults to `161`.
* `node['zabbix']['host']['snmp']['use_ip']` -  Defaults to `true`.
* `node['zabbix']['host']['agent']['use_ip']` -  Defaults to `true`.
* `node['zabbix']['java_gateway']['enabled']` -  Defaults to `false`.
* `node['zabbix']['java_gateway']['config']` -  Defaults to `{ ... }`.
* `node['zabbix']['server']['database']['mysql']['filesystem']` -  Defaults to `ext4`.
* `node['zabbix']['server']['database']['mysql']['lvm_group']` -  Defaults to `shared`.
* `node['zabbix']['server']['database']['mysql']['lvm_volume']` -  Defaults to `/dev/sda3`.
* `node['zabbix']['server']['database']['mysql']['partition_size']` -  Defaults to `10G`.
* `node['zabbix']['server']['database']['mysql']['mount_point']` -  Defaults to `/var/lib/mysql_zabbix`.
* `node['zabbix']['server']['database']['mysql']['databag']` -  Defaults to `zabbix`.
* `node['zabbix']['server']['database']['mysql']['version']` -  Defaults to `5.5`.
* `node['zabbix']['server']['database']['mysql']['service_name']` -  Defaults to `zabbix`.
* `node['zabbix']['server']['database']['mysql']['database_name']` -  Defaults to `zabbix`.
* `node['zabbix']['server']['database']['mysql']['configuration']['listen_addresses']` -  Defaults to `127.0.0.1`.
* `node['zabbix']['server']['database']['mysql']['configuration']['port']` -  Defaults to `3306`.
* `node['zabbix']['server']['database']['mysql']['configuration']['character_set']` -  Defaults to `utf8`.
* `node['zabbix']['server']['database']['mysql']['configuration']['collate']` -  Defaults to `utf8_bin`.
* `node['zabbix']['server']['database']['postgresql']['filesystem']` -  Defaults to `ext4`.
* `node['zabbix']['server']['database']['postgresql']['lvm_group']` -  Defaults to `shared`.
* `node['zabbix']['server']['database']['postgresql']['lvm_volume']` -  Defaults to `/dev/sda3`.
* `node['zabbix']['server']['database']['postgresql']['partition_size']` -  Defaults to `10G`.
* `node['zabbix']['server']['database']['postgresql']['cluster']` -  Defaults to `main`.
* `node['zabbix']['server']['database']['postgresql']['databag']` -  Defaults to `zabbix`.
* `node['zabbix']['server']['database']['postgresql']['locale']` -  Defaults to `en_US.utf8`.
* `node['zabbix']['server']['database']['postgresql']['mount_point']` -  Defaults to `/var/lib/postgresql`.
* `node['zabbix']['server']['database']['postgresql']['network']` -  Defaults to `127.0.0.0/8`.
* `node['zabbix']['server']['database']['postgresql']['version']` -  Defaults to `9.4`.
* `node['zabbix']['server']['database']['postgresql']['configuration']['listen_addresses']` -  Defaults to `127.0.0.1`.
* `node['zabbix']['server']['database']['postgresql']['configuration']['port']` -  Defaults to `5432`.
* `node['zabbix']['server']['database']['postgresql']['configuration']['max_connections']` -  Defaults to `300`.
* `node['zabbix']['server']['database']['postgresql']['configuration']['shared_buffers']` -  Defaults to `128MB`.
* `node['zabbix']['server']['database']['postgresql']['configuration']['maintenance_work_mem']` -  Defaults to `128MB`.
* `node['zabbix']['server']['database']['postgresql']['configuration']['work_mem']` -  Defaults to `8MB`.
* `node['zabbix']['server']['database']['postgresql']['configuration']['effective_cache_size']` -  Defaults to `2GB`.
* `node['zabbix']['server']['database']['postgresql']['configuration']['log_min_duration_statement']` -  Defaults to `1000`.
* `node['zabbix']['server']['database']['postgresql']['configuration']['archive_mode']` -  Defaults to `on`.
* `node['zabbix']['server']['database']['postgresql']['configuration']['archive_command']` -  Defaults to `exit 0`.
* `node['zabbix']['server']['database']['postgresql']['configuration']['wal_level']` -  Defaults to `archive`.

## MySQL
* `node['zabbix']['server']['database']['mysql']['filesystem']` - Defaults to `ext4`
* `node['zabbix']['server']['database']['mysql']['lvm_group']` - Defaults to `shared`
* `node['zabbix']['server']['database']['mysql']['lvm_volume']` - Defaults to `/dev/sda3`
* `node['zabbix']['server']['database']['mysql']['partition_size']` - Defaults to `10G`
* `node['zabbix']['server']['database']['mysql']['mount_point']` - Defaults to `/var/lib/mysql_zabbix`. Do not set to `/var/lib/mysql` because it will conflict.
* `node['zabbix']['server']['database']['mysql']['databag']` - Defaults to `zabbix`
* `node['zabbix']['server']['database']['mysql']['version']` - Defaults to `5.5`
* `node['zabbix']['server']['database']['mysql']['service_name']` - Defaults to `zabbix`
* `node['zabbix']['server']['database']['mysql']['database_name']` - Defaults to `zabbix`
* `node['zabbix']['server']['database']['mysql']['configuration']['listen_addresses']` - Defaults to `127.0.0.1`
* `node['zabbix']['server']['database']['mysql']['configuration']['port']` - Defaults to `3306`
* `node['zabbix']['server']['database']['mysql']['configuration']['character_set']` - Defaults to `utf8`
* `node['zabbix']['server']['database']['mysql']['configuration']['collate']` - Defaults to `utf8_bin`

## Default
* `node['zabbix']['version']` -  Defaults to `3.2`.
* `node['zabbix']['api-version']` -  Defaults to `3.1.0`.
* `node['zabbix']['server']['database']['vendor']` -  Defaults to `postgresql`. Make sure that is setup for MySQL.

## Host
* `node['zabbix']['host']['group']` -  Defaults to `Hosts`.
* `node['zabbix']['host']['name']` -  Defaults to `node['fqdn']`.
* `node['zabbix']['host']['dns']` -  Defaults to `node['fqdn']`.
* `node['zabbix']['host']['ipaddress']` -  Defaults to `node['ipaddress']`.
* `node['zabbix']['host']['ipmi']['enabled']` -  Defaults to `false`.
* `node['zabbix']['host']['ipmi']['port']` -  Defaults to `623`.
* `node['zabbix']['host']['ipmi']['use_ip']` -  Defaults to `true`.
* `node['zabbix']['host']['jmx']['enabled']` -  Defaults to `false`.
* `node['zabbix']['host']['jmx']['port']` -  Defaults to `12345`.
* `node['zabbix']['host']['jmx']['use_ip']` -  Defaults to `true`.
* `node['zabbix']['host']['snmp']['enabled']` -  Defaults to `false`.
* `node['zabbix']['host']['snmp']['port']` -  Defaults to `161`.
* `node['zabbix']['host']['snmp']['use_ip']` -  Defaults to `true`.
* `node['zabbix']['host']['agent']['use_ip']` -  Defaults to `true`.

## Java Gateway
* `node['zabbix']['java_gateway']['enabled']` -  Defaults to `false`.
* `node['zabbix']['java_gateway']['timeout']` -  Defaults to `3`.
* `node['zabbix']['java_gateway']['listen_ip']` -  Defaults to `127.0.0.1`.
* `node['zabbix']['java_gateway']['listen_port']` -  Defaults to `10052`.
* `node['zabbix']['java_gateway']['pollers']` -  Defaults to `5`.

## Server
* `node['zabbix']['server']['database']['vendor']` -  Defaults to `postgresql`.
* `node['zabbix']['server']['service']` -  Defaults to `zabbix-server`.
* `node['zabbix']['server']['credentials']['databag']` -  Defaults to `zabbix`.
* `node['zabbix']['server']['templates']` -  Defaults to `/opt/zabbix/templates`.
* `node['zabbix']['server']['sync_hosts']` -  Defaults to `false`.
* `node['zabbix']['server']['config']['listenip']` -  Defaults to `0.0.0.0`.
* `node['zabbix']['server']['config']['debuglevel']` -  Defaults to `3`.
* `node['zabbix']['server']['config']['workers']` -  Defaults to `{ ... }`.
* `node['zabbix']['server']['config']['hk']` -  Defaults to `{ ... }`.
* `node['zabbix']['server']['config']['cache']` -  Defaults to `{ ... }`.
* `node['zabbix']['server']['config']['timeouts']` -  Defaults to `{ ... }`.
* `node['zabbix']['server']['config']['global']` -  Defaults to `{ ... }`.
* `node['zabbix']['server']['config']['java_gateway']` -  Defaults to `{ ... }`.
* `node['zabbix']['server']['config']['alerts']` -  Defaults to `{ ... }`.
* `node['zabbix']['server']['web']['server_name']` -  Defaults to `localhost`.
* `node['zabbix']['server']['web']['listen']` -  Defaults to `127.0.0.1`.
* `node['zabbix']['server']['web']['port']` -  Defaults to `9200`.
* `node['zabbix']['server']['web']['max_requests']` -  Defaults to `500`.
* `node['zabbix']['server']['web']['max_children']` -  Defaults to `5`.
* `node['zabbix']['server']['web']['min_spare_servers']` -  Defaults to `1`.
* `node['zabbix']['server']['web']['start_servers']` -  Defaults to `2`.
* `node['zabbix']['server']['web']['max_spare_servers']` -  Defaults to `3`.
* `node['zabbix']['server']['web']['process_manager']` -  Defaults to `dynamic`.
* `node['zabbix']['server']['web']['configuration']['php_admin_value[date.timezone]']` -  Defaults to `UTC`.
* `node['zabbix']['server']['web']['configuration']['php_admin_flag[display_errors]']` -  Defaults to `false`.
* `node['zabbix']['server']['web']['configuration']['php_admin_value[error_reporting]']` -  Defaults to `E_ALL &amp; ~E_DEPRECATED`.
* `node['zabbix']['server']['web']['configuration']['php_admin_value[error_log]']` -  Defaults to `/var/log/zabbix-php-error.log`.
* `node['zabbix']['server']['web']['configuration']['php_admin_value[max_execution_time]']` -  Defaults to `600`.
* `node['zabbix']['server']['web']['configuration']['php_admin_value[max_input_time]']` -  Defaults to `300`.
* `node['zabbix']['server']['web']['configuration']['php_admin_value[memory_limit]']` -  Defaults to `128M`.
* `node['zabbix']['server']['web']['configuration']['php_admin_value[post_max_size]']` -  Defaults to `32M`.
* `node['zabbix']['server']['web']['configuration']['php_admin_flag[register_globals]']` -  Defaults to `true`.
* `node['nginx']['default_site_enabled']` -  Defaults to `false`.

# Recipes

* zabbix_lwrp::agent_linux - Installs and configures Zabbix agent for Linux.
* zabbix_lwrp::agent_win_bin - Installs and configures Zabbix agent for Windows.
* zabbix_lwrp::agent_win_choco - Installs and configures Zabbix agent for Windows.
* zabbix_lwrp::agent - Installs and configures Zabbix agent.
* zabbix_lwrp::connect - Connects to Zabbix API to sync configuration.
* zabbix_lwrp::default - Installs and configures Zabbix official repository and agent.
* zabbix_lwrp::postgresql - Installs and configures PostgreSQL database for Zabbix.
* zabbix_lwrp::mysql - Installs and configures MySQL database for Zabbix.
* zabbix_lwrp::database - Installs and configures Zabbix database.
* zabbix_lwrp::default - Installs and configures Zabbix official repository and agent.
* zabbix_lwrp::host - Creates host via Zabbix API.
* zabbix_lwrp::java_gateway - Installs and configures Zabbix Java Gateway.
* zabbix_lwrp::partition - Configures LVM for Zabbix database.
* zabbix_lwrp::repository - Installs Zabbix official repository.
* zabbix_lwrp::server - Installs and configures Zabbix server.
* zabbix_lwrp::web - Installs and configures Zabbix frontend.

# Resources

* [zabbix_action](#zabbix_action)
* [zabbix_application](#zabbix_application)
* [zabbix_connect](#zabbix_connect)
* [zabbix_database](#zabbix_database)
* [zabbix_graph](#zabbix_graph)
* [zabbix_host](#zabbix_host)
* [zabbix_media_type](#zabbix_media_type)
* [zabbix_screen](#zabbix_screen)
* [zabbix_template](#zabbix_template)
* [zabbix_user_group](#zabbix_user_group)
* [zabbix_user_macro](#zabbix_user_macro)

## zabbix_action

### Actions

- sync:  Default action.

### Attribute Parameters

- name:
- event_source:
- escalation_time:  Defaults to <code>60</code>.
- enabled:  Defaults to <code>true</code>.
- message_subject:
- message_body:
- send_recovery_message:  Defaults to <code>false</code>.
- recovery_message_subject:
- recovery_message_body:

## zabbix_application

### Actions

- sync:  Default action.

### Attribute Parameters

- name:

## zabbix_connect

### Actions

- make:  Default action.

### Attribute Parameters

- name:
- databag:
- apiurl:
- user:
- password:
- sync:  Defaults to <code>false</code>.

## zabbix_database

### Actions

- create:  Default action.

### Attribute Parameters

- db_vendor:  Defaults to <code>"postgresql"</code>.
- db_name:
- db_user:
- db_pass:
- db_host:
- db_port:

## zabbix_graph

### Actions

- create:  Default action.

### Attribute Parameters

- name:
- height:
- width:
- graph_items:
- graph_type:

## zabbix_host

### Actions

- create:  Default action.

### Attribute Parameters

- type:  Defaults to <code>1</code>.
- host_name:
- host_group:
- port:  Defaults to <code>10050</code>.
- ip_address:
- dns:
- use_ip:  Defaults to <code>true</code>.
- ipmi_enabled:  Defaults to <code>false</code>.
- snmp_enabled:  Defaults to <code>false</code>.
- jmx_enabled:  Defaults to <code>false</code>.
- ipmi_port:  Defaults to <code>623</code>.
- snmp_port:  Defaults to <code>161</code>.
- jmx_port:  Defaults to <code>12345</code>.
- ipmi_use_ip:  Defaults to <code>true</code>.
- snmp_use_ip:  Defaults to <code>true</code>.
- jmx_use_ip:  Defaults to <code>true</code>.

## zabbix_media_type

### Actions

- create:  Default action.

### Attribute Parameters

- name:
- type:
- server:
- helo:
- email:
- path:
- gsm_modem:
- username:
- password:

## zabbix_screen

### Actions

- sync:  Default action.

### Attribute Parameters

- name:
- hsize:
- vsize:

## zabbix_template

### Actions

- add:  Default action.
- import:

### Attribute Parameters

- host_name:
- path:

## zabbix_user_group

### Actions

- create:  Default action.

### Attribute Parameters

- name:

## zabbix_user_macro

### Actions

- create:  Default action.

### Attribute Parameters

- name:
- value:
- host_name:

# Data bag

Data bag `zabbix` must contains the following items:
* admin (with Zabbix admin password)
* postgresql
* users

`postgresql` and `users` items related to the postgresql database

`users` item related to MySQL database, necessarily contains `root` and `zabbix` entries

For examples see fixture data bag `test/fixtures/databags/zabbix/`

## Using node.run_state
Optionally this data can be provided in node.run_state instead of data bags.

This is useful in a wrapper cookbook that retrieves credentials from other locations such as chef-vault.

Simply set the 'databag' attributes to the value of the run_state key that contains the data.

### Example Wrapper Cookbook
```ruby
  #Your super secret code to get credentials here
  
  node.default['zabbix']['server']['database']['databag'] = 'zabbix_data'
  node.default['zabbix']['server']['database']['postgresql']['databag'] = 'zabbix_data'
  node.default['zabbix']['server']['credentials']['databag'] = 'zabbix_data'

  node.run_state['zabbix_data'] = {
    'users' => {
      'id' => 'users',
      'users' => {
        'zabbix' => {
          'options' => {
             'password' => secret_zabbix_pass_here
             'superuser' => false
           }
         }
       }
    },
    'databases' => {
      'id' => 'databases',
      'databases' => {
        'zabbix' => { 'options' => { 'owner' => 'zabbix' } }
      }
    },
    'admin' => {'id' => 'admin', 'pass' => secret_admin_pass_here }
  }

  include_recipe 'zabbix_lwrp::default'
  include_recipe 'zabbix_lwrp::database'
  include_recipe 'zabbix_lwrp::server'
  include_recipe 'zabbix_lwrp::web'
```


# Resources

This cookbooks provides next resources:
* [zabbix_action](#zabbix_action)
* [zabbix_application](#zabbix_application)
* [zabbix_connect](#zabbix_connect)
* [zabbix_database](#zabbix_database)
* [zabbix_graph](#zabbix_graph)
* [zabbix_host](#zabbix_host)
* [zabbix_media_type](#zabbix_media_type)
* [zabbix_screen](#zabbix_screen)
* [zabbix_template](#zabbix_template)
* [zabbix_user_group](#zabbix_user_group)
* [zabbix_user_macro](#zabbix_user_macro)

## zabbix_action

Creates zabbix action with operations, conditions and messages.

### Actions
<table>
  <tr>
    <th>Action</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>sync</td>
    <td>Default action. Sync action description with one's in zabbix server</td>
  </tr>
</table>

### Attributes
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>name</td>
    <td><strong>Name attribute</strong>. Name of the action (required)</td>
    <td></td>
  </tr>
  <tr>
    <td>event_source</td>
    <td>Source of event for action, now only :trigger allowed</td>
    <td>:triggers</td>
  </tr>
  <tr>
    <td>escalation_time</td>
    <td>Delay between escalation steps</td>
    <td>60</td>
  </tr>
  <tr>
    <td>enabled</td>
    <td>Is action enabled?</td>
    <td>true</td>
  </tr>
  <tr>
    <td>message_subject</td>
    <td>Subject of action message</td>
    <td></td>
  </tr>
  <tr>
    <td>message_body</td>
    <td>Body of action message</td>
    <td>true</td>
  </tr>
  <tr>
    <td>send_recovery_message</td>
    <td>Send recovery message when conditions of action become false</td>
    <td>false</td>
  </tr>
  <tr>
    <td>recovery_message_subject</td>
    <td>Subject of recovery message</td>
    <td></td>
  </tr>
  <tr>
    <td>recovery_message_body</td>
    <td>Body of recovery message</td>
    <td></td>
  </tr>
  <tr>
    <td>operation</td>
    <td>Add an operation to action, see below. It's possible to add more then one operation</td>
    <td></td>
  </tr>
  <tr>
    <td>condition</td>
    <td>Add an condition to action, see below. It's possible to add more the one condition</td>
    <td></td>
  </tr>
</table>

Attributes for operation.
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>type</td>
    <td>Type of operation, can be :message or :command</td>
    <td>:message</td>
  </tr>
  <tr>
    <td>escalation_time</td>
    <td>Time to escalate to next step</td>
    <td></td>
  </tr>
  <tr>
    <td>start</td>
    <td>Start step, when this operation take place</td>
    <td></td>
  </tr>
  <tr>
    <td>stop</td>
    <td>Last step, when this operation take place</td>
    <td></td>
  </tr>
  <tr>
    <td>user_groups</td>
    <td>Zabbix user group names that'll receive message</td>
    <td></td>
  </tr>
  <tr>
    <td>message</td>
    <td>Message description, see below</td>
    <td>Use default actin message if empty</td>
  </tr>
</table>

Attributes for conditions.
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>type</td>
    <td>Type of condition, can be one of :trigger, :trigger_value, :trigger_serverity, :host_group, :maintenance</td>
    <td></td>
  </tr>
  <tr>
    <td>operator</td>
    <td>Operator for condition, can be one of :equal, :not_equal, :like, :not_like, :in, :gte, :lte, :not_in</td>
    <td></td>
  </tr>
  <tr>
    <td>value</td>
    <td>Value for condition.</td>
    <td></td>
  </tr>
</table>

It also possible to use short form of condition, like:
```ruby
  condition :trigger, :equal, '42th trigger name'
```

Attributes for message.
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>use_default_message</td>
    <td>Use default message from action</td>
    <td></td>
  </tr>
  <tr>
    <td>subject</td>
    <td>Message subject</td>
    <td></td>
  </tr>
  <tr>
    <td>message</td>
    <td>Message body</td>
    <td></td>
  </tr>
  <tr>
    <td>media_type</td>
    <td>Name of media type to use</td>
    <td>By default all media types are used</td>
  </tr>
</table>

### Examples
```ruby
zabbix_action 'Test action' do
  action :sync
  event_source :triggers
  operation do
    user_groups 'Test group'
    message do
      use_default_message false
      subject 'Test {TRIGGER.SEVERITY}: {HOSTNAME1} {TRIGGER.STATUS}: {TRIGGER.NAME}'
      message "Trigger: {TRIGGER.NAME}\n"\
        "Trigger status: {TRIGGER.STATUS}\n" \
        "Trigger severity: {TRIGGER.SEVERITY}\n" \
        "\n" \
        "Item values:\n" \
        '{ITEM.NAME1} ({HOSTNAME1}:{TRIGGER.KEY1}): {ITEM.VALUE1}'
      media_type 'sms'
    end
  end

  condition :trigger_severity, :gte, :high
  condition :host_group, :equal, 'Main'
  condition :maintenance, :not_in, :maintenance
end

```


## zabbix_application

Creates application, items and triggers. You should think about items and triggers like nested
resources inside zabbix_application resource.

### Actions
<table>
  <tr>
    <th>Action</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>sync</td>
    <td>Default action. Sync application description with one's in zabbix server</td>
  </tr>
</table>

### Attributes
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>name</td>
    <td><strong>Name attribute</strong>. Name of the application (required)</td>
    <td></td>
  </tr>
  <tr>
    <td>item</td>
    <td>Add an item to application, see below. It's possible to add more then one item</td>
    <td></td>
  </tr>
  <tr>
    <td>trigger</td>
    <td>Add an trigger to application, see below. It's possible to add more the one trigger</td>
    <td></td>
  </tr>
</table>

### Item attributes
Create/update zabbix item
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>key</td>
    <td><strong>Name attribute</strong>. Zabbix key for an item, should be unique.</td>
    <td></td>
  </tr>
  <tr>
    <td>type</td>
    <td>Type of zabbix check, possible values
      :zabbix, :trapper, :active, :calculated
    </td>
    <td></td>
  </tr>
  <tr>
    <td>name</td>
    <td>Descriptive name of zabbix check, shown in web-interface
    </td>
    <td></td>
  </tr>
  <tr>
    <td>frequency</td>
    <td>How often zabbix checks this item in seconds</td>
    <td>60</td>
  </tr>
  <tr>
    <td>history</td>
    <td>How many days store item's history</td>
    <td>7 days</td>
  </tr>
  <tr>
    <td>multiplier</td>
    <td>Set a multiplier for item</td>
    <td>0</td>
  </tr>
  <tr>
    <td>trends</td>
    <td>How many days store item's trends (archived history)</td>
    <td>365</td>
  </tr>
  <tr>
    <td>units</td>
    <td>Set a unit for item</td>
    <td></td>
  </tr>
  <tr>
    <td>value_type</td>
    <td>Type of gathered value, possible values
      :float, :character, :log_line, :unsigned_int, :text
    </td>
    <td>:unsigned_int</td>
  </tr>
</table>

### Trigger attributes
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
</table>

### Examples
```ruby
zabbix_application "Test application" do
  action :sync

  item 'vfs.fs.size[/var/log,free]' do
    type :active
    name 'Free disk space on /var/log'
    frequency 600
    value_type :unsigned_int
  end

  trigger "Number #{node.fqdn} of free inodes on log < 10%" do
    expression "{#{node.fqdn}:vfs.fs.size[/var/log,free].last(0)}>0"
    severity :high
  end
end
```

## zabbix_connect

### Examples
```ruby

zabbix_connect 'default' do
  action :make
  apiurl 'http://localhost/api_jsonrpc.php'
  databag 'zabbix'
end
```

## zabbix_database

### Examples
```ruby

zabbix_database db_name do
  db_user db_user
  db_pass db_pass
  db_host db_host
  db_port db_port
  action :create
end
```

## zabbix_graph

### Examples
```ruby

zabbix_graph 'Test Graph' do
  action :create
  width 640
  height 480
  graph_items [:key => 'vfs.fs.size[/var/log,free]', :color => '111111']
end
```

## zabbix_host

### Examples
```ruby
zabbix_host node['fqdn'] do
  action :create
  host_group 'Hosts'
  use_ip true
  ip_address node['ipaddress']
end
```

## zabbix_media_type

### Examples
```ruby
zabbix_media_type 'sms' do
  action :create
  type :sms
  gsm_modem '/dev/modem'
end
```

## zabbix_screen

### Examples
```ruby
zabbix_screen 'Test Screen' do
  action :sync
  screen_item 'Test Graph' do
    resource_type :graph
  end
end
```

## zabbix_template

### Actions
<table>
  <tr>
    <th>Action</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>add</td>
    <td>Default action. Add a template to node</td>
  </tr>
  <tr>
    <td>import</td>
    <td>Import templates from xml file to zabbix server</td>
  </tr>
</table>

### Attributes
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>path</td>
    <td><strong>Name attribute</strong>. Path to file for :import or name of template for :add action (required)</td>
    <td></td>
  </tr>
  <tr>
    <td>host_name</td>
    <td>Name of host new template to add</td>
    <td>FQDN of current node</td>
  </tr>
</table>

### Examples
```ruby
zabbix_template '/opt/zabbix/templates/zbx_templates_linux.xml' do
  action :import
end

zabbix_template 'Linux_Template'
  action :add
end
```

## zabbix_user_group

### Actions
<table>
  <tr>
    <th>Action</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>create</td>
    <td>Default action. Create a new zabbix user group</td>
  </tr>
</table>

### Attributes
<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>name</td>
    <td><strong>Name attribute</strong>. Name of new zabbix user group (required)</td>
    <td></td>
  </tr>
</table>

### Examples
```ruby
zabbix_user_group 'Test group' do
  action :create
end
```

## zabbix_user_macro

### Examples
```ruby
zabbix_user_macro 'Test_macro' do
  action :create
  value 'foobar'
end
```


# Usage

To install Zabbix agent just include `zabbix_lwrp` default recipe into your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[zabbix_lwrp]"
  ]
}
```

This recipe should be included before all usage of LWRP, because connection to zabbix server is established here.

To install Zabbix server include the following recipes:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[zabbix_lwrp::default]",
    "recipe[zabbix_lwrp::database]",
    "recipe[zabbix_lwrp::server]",
    "recipe[zabbix_lwrp::web]"
  ]
}
```

For examples of LWRP see fixture cookbook in `tests/fixtures/cookbooks`.


# License and Maintainer

Maintainer:: LLC Express 42 (<cookbooks@express42.com>)
Source:: https://github.com/express42/zabbix_lwrp
Issues:: https://github.com/express42/zabbix_lwrp/issues

License:: MIT
