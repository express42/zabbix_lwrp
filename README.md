# Description

Installs and configures Zabbix agent and server with PostgreSQL and Nginx. Provides LWRP for creating and modifying Zabbix objects.

# Requirements

## Platform:

* Ubuntu

## Cookbooks:

* apt
* build-essential
* lvm
* nginx
* postgresql_lwrp
* php-fpm

# Attributes

## Default attributes

* `node['zabbix']['version']` -  Defaults to `"2.4"`.
* `node['zabbix']['api-version']` -  Defaults to `"2.4.2"`.

## Agent attributes

* `node['zabbix']['agent']['include']` -  Defaults to `"/opt/zabbix/etc"`.
* `node['zabbix']['agent']['scripts']` -  Defaults to `"/opt/zabbix/scripts"`.
* `node['zabbix']['agent']['templates']` -  Defaults to `"/opt/zabbix/templates"`.
* `node['zabbix']['agent']['loglevel']` -  Defaults to `"3"`.
* `node['zabbix']['agent']['remotecmds']` -  Defaults to `"0"`.
* `node['zabbix']['agent']['timeout']` -  Defaults to `"3"`.
* `node['zabbix']['agent']['enable_remote_commands']` -  Defaults to `"0"`.
* `node['zabbix']['agent']['listen_ip']` -  Defaults to `"0.0.0.0"`.
* `node['zabbix']['agent']['serverhost']` -  Defaults to `"127.0.0.1"`.
* `node['zabbix']['agent']['user_params']` -  Defaults to `"{ ... }"`.

## Database attributes

* `node['zabbix']['server']['database']['filesystem']` -  Defaults to `ext4`.
* `node['zabbix']['server']['database']['lvm_group']` -  Defaults to `shared`.
* `node['zabbix']['server']['database']['lvm_volume']` -  Defaults to `/dev/sda3`.
* `node['zabbix']['server']['database']['partition_size']` -  Defaults to `10G`.
* `node['zabbix']['server']['database']['cluster']` -  Defaults to `main`.
* `node['zabbix']['server']['database']['databag']` -  Defaults to `zabbix`.
* `node['zabbix']['server']['database']['locale']` -  Defaults to `en_US.utf8`.
* `node['zabbix']['server']['database']['mount_point']` -  Defaults to `/var/lib/postgresql`.
* `node['zabbix']['server']['database']['network']` -  Defaults to `127.0.0.0/8`.
* `node['zabbix']['server']['database']['version']` -  Defaults to `9.4`.
* `node['zabbix']['server']['database']['configuration']['listen_addresses']` -  Defaults to `"127.0.0.1"`.
* `node['zabbix']['server']['database']['configuration']['port']` -  Defaults to `"5432"`.
* `node['zabbix']['server']['database']['configuration']['max_connections']` -  Defaults to `"300"`.
* `node['zabbix']['server']['database']['configuration']['shared_buffers']` -  Defaults to `"128MB"`.
* `node['zabbix']['server']['database']['configuration']['maintenance_work_mem']` -  Defaults to `"128MB"`.
* `node['zabbix']['server']['database']['configuration']['work_mem']` -  Defaults to `"8MB"`.
* `node['zabbix']['server']['database']['configuration']['effective_cache_size']` -  Defaults to `"2GB"`.
* `node['zabbix']['server']['database']['configuration']['log_min_duration_statement']` -  Defaults to `"1000"`.
* `node['zabbix']['server']['database']['configuration']['archive_mode']` -  Defaults to `"on"`.
* `node['zabbix']['server']['database']['configuration']['archive_command']` -  Defaults to `"exit 0"`.

## Server attributes

* `node['zabbix']['server']['service']` -  Defaults to `"zabbix-server"`.
* `node['zabbix']['server']['credentials']['databag']` -  Defaults to `"zabbix"`.
* `node['zabbix']['server']['config']['listenip']` -  Defaults to `"0.0.0.0"`.
* `node['zabbix']['server']['config']['debuglevel']` -  Defaults to `"3"`.
* `node['zabbix']['server']['config']['workers']` -  Defaults to `"{ ... }"`.
* `node['zabbix']['server']['config']['hk']` -  Defaults to `"{ ... }"`.
* `node['zabbix']['server']['config']['cache']` -  Defaults to `"{ ... }"`.
* `node['zabbix']['server']['config']['timeouts']` -  Defaults to `"{ ... }"`.
* `node['zabbix']['server']['config']['global']` -  Defaults to `"{ ... }"`.
* `node['zabbix']['server']['config']['alerts']` -  Defaults to `"{ ... }"`.

## Frontend attributes

* `node['zabbix']['server']['web']['server_name']` -  Defaults to `localhost`.
* `node['zabbix']['server']['web']['listen']` -  Defaults to `127.0.0.1`.
* `node['zabbix']['server']['web']['port']` -  Defaults to `9200`.
* `node['zabbix']['server']['web']['max_requests']` -  Defaults to `500`.
* `node['zabbix']['server']['web']['max_children']` -  Defaults to `5`.
* `node['zabbix']['server']['web']['min_spare_servers']` -  Defaults to `1`.
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

# Recipes

* zabbix_lwrp::agent - Installs and configures Zabbix agent.
* zabbix_lwrp::connect - Connects to Zabbix API to sync configuration.
* zabbix_lwrp::default - Installs and configures Zabbix official repository and agent.
* zabbix_lwrp::database - Installs and configures Zabbix database.
* zabbix_lwrp::host - Creates host via Zabbix API.
* zabbix_lwrp::partition - Configures LVM for Zabbix database.
* zabbix_lwrp::repository - Installs Zabbix official repository.
* zabbix_lwrp::server - Installs and configures Zabbix server.
* zabbix_lwrp::web - Installs and configures Zabbix frontend.

# Data bag

Data bag `zabbix` must contains the following items:
* admin (with Zabbix admin password)
* databases
* users

`databases` and `users` items related to the postgresql database (see [postgresql_lwrp](https://github.com/express42-cookbooks/postgresql) cookbook)

For examples see fixture data bag `test/fixtures/databags/zabbix/`


# LWRP

This cookbooks provides next resources:
* [zabbix_lwrp_action](#zabbix_lwrp_action)
* [zabbix_lwrp_application](#zabbix_lwrp_application)
* [zabbix_lwrp_graph](#zabbix_lwrp_graph)
* [zabbix_lwrp_host](#zabbix_lwrp_host)
* [zabbix_lwrp_media_type](#zabbix_lwrp_media_type)
* [zabbix_lwrp_screen](#zabbix_lwrp_screen)
* [zabbix_lwrp_template](#zabbix_lwrp_template)
* [zabbix_lwrp_user_group](#zabbix_lwrp_user_group)

## zabbix_lwrp_action

zabbix_lwrp_action LWRP creates zabbix action with operations, conditions and messages.

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
zabbix_lwrp_action 'Some disturbance in force' do
  event_source :triggers
  operation do
    user_groups 'Ultimate Question Group'
  end

  condition :trigger, :equal, "#{node.fqdn}: Number of free inodes on log < 10%"
  condition :trigger_value, :equal, :problem
  condition :trigger_severity, :gte, :high
  condition :host_group, :equal, 'My Favorite Host Group'
  condition :maintenance, :not_in, :maintenance
end

```


## zabbix_lwrp_application

zabbix_lwrp_application lwrp creates application, items and triggers. You should think about items and triggers like nested
resources inside zabbix_lwrp_application lwrp.

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
zabbix_lwrp_application "Test application" do
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

## zabbix_lwrp_graph

### Examples
```ruby

zabbix_lwrp_graph 'Graph 1' do
  width 640
  height 480
  graph_items [:key => 'vfs.fs.size[/var/log,free]', :color => '111111']
end
```

## zabbix_lwrp_host

### Examples
```ruby
zabbix_lwrp_host node.fqdn do
  host_group 'My Favorite Host Group'
  use_ip true
  ip_address '127.0.0.1'
end
```

## zabbix_lwrp_media_type

### Examples
```ruby
zabbix_lwrp_media_type 'sms' do
  type :sms
  modem '/dev/modem'
end
```

## zabbix_lwrp_screen


### Examples
```ruby
zabbix_lwrp_screen 'Screen 1' do
  screen_item 'Graph 1' do
    resource_type :graph
  end
end
```

## zabbix_lwrp_template

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
zabbix_lwrp_template '/tmp/zbx_templates_linux.xml' do
  action :import
end

zabbix_lwrp_template 'Linux_Template'
```

## zabbix_lwrp_user_group

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
zabbix_lwrp_user_group 'Ultimate Question Group'
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

License:: MIT
