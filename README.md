Zabbix Cookbook
======================

Install and configure zabbix-agent. Also contains a LWRP for creating all zabbix stuff like items, triggers, actions,
hosts, screens and so on.

Requirements
------------

Tested only on Ubuntu 12.04, but should works on Debian too. Works only with zabbix version 2.0.4

Attributes
----------

#### zabbix::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['zabbix']['client']['include']</tt></td>
    <td>String</td>
    <td>Path for additional scripts and user parameters </td>
    <td><tt>/opt/zabbix/etc</tt></td>
  </tr>
  <tr>
    <td><tt>['zabbix']['client']['loglevel']</tt></td>
    <td>Integer</td>
    <td>Log level for zabbix client</td>
    <td><tt>3</tt></td>
  </tr>
  <tr>
    <td><tt>['zabbix']['client']['serverip']</tt></td>
    <td>String</td>
    <td>IP address of zabbix server. If none, cookbook try to search for nodes with roles 'zabbix-proxy' or 'zabbix-server'.</td>
    <td><tt>not defined</tt></td>
  </tr>
</table>

Usage
-----
#### zabbix::default

Just include `zabbix` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[zabbix]"
  ]
}
```

#### zabbix::example

Here an examples of usage of LWRP

LWRP
----

This cookbooks provides next resources:
* [zabbix_action](#zabbix_action)
* [zabbix_application](#zabbix_application)
* [zabbix_graph](#zabbix_graph)
* [zabbix_host](#zabbix_host)
* [zabbix_media_type](#zabbix_media_type)
* [zabbix_screen](#zabbix_screen)
* [zabbix_template](#zabbix_template)
* [zabbix_user_group](#zabbix_user_group)

## zabbix_action
```ruby
zabbix_action 'My favorite action' do
  event_source :triggers
  operation do
    user_groups 'My Beloved group'
  end

  condition :trigger, :equal, "Number #{node.fqdn} of free inodes on log < 10%"
  condition :trigger_value, :equal, :problem
  condition :trigger_severity, :gte, :high
  condition :host_group, :equal, 'My Favorite Host Group'
  condition :maintenance, :not_in, :maintenance
end

```


## zabbix_application

## zabbix_graph

## zabbix_host

## zabbix_media_type

## zabbix_screen

## zabbix_template

### Actions
<table>
  <tr>
    <th>Action</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>add</tt></td>
    <td>Default action. Add a template to node</td>
  </tr>
  <tr>
    <td><tt>import</tt></td>
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
    <td><tt>path</tt></td>
    <td><strong>Name attribute</strong>. Path to file for :import or name of template for :add action (required)</td>
    <td></td>
  </tr>
  <tr>
    <td><tt>host_name</tt></td>
    <td>Name of host new template to add</td>
    <td>FQDN of current node</td>
  </tr>
</table>

### Examples
```ruby
zabbix_template "/tmp/zbx_templates_base_e42.xml" do
  action :import
end

zabbix_template "CPU_E42_Template"
```

## zabbix_user_group

### Actions
<table>
  <tr>
    <th>Action</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>create</tt></td>
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
    <td><tt>name</tt></td>
    <td><strong>Name attribute</strong>. Name of new zabbix user group (required)</td>
    <td></td>
  </tr>
</table>

### Examples
```ruby
zabbix_user_group 'Ultimate Question Group'
```


Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Author:: Ivan Evtuhovich <ivan@express42.com>
Author:: Alexander Titov <alex@express42.com>

Copyright 2012-2013, Express 42, LLC
