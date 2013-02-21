Zabbix Cookbook
======================

Install and configure zabbix-agent. Also contains a LWRP for creating all zabbix stuff like items, triggers, actions,
hosts, screens and so on.

Requirements
------------

Tested only on Ubuntu 12.04, but should works on Debian too. Works only with zabbix version 2.0.4 and 2.0.5.

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
    <td>['zabbix']['client']['include']</td>
    <td>String</td>
    <td>Path for additional scripts and user parameters </td>
    <td>/opt/zabbix/etc</td>
  </tr>
  <tr>
    <td>['zabbix']['client']['loglevel']</td>
    <td>Integer</td>
    <td>Log level for zabbix client</td>
    <td>3</td>
  </tr>
  <tr>
    <td>['zabbix']['client']['serverip']</td>
    <td>String</td>
    <td>IP address of zabbix server. If none, cookbook try to search for nodes with roles 'zabbix-proxy' or 'zabbix-server'.</td>
    <td>not defined</td>
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

This recipe should be included before all usage of LWRP, because connection to zabbix server is established here.

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

zabbix_action LWRP creates zabbix action with operations, conditions and messages.

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
zabbix_action 'Some disturbation in force' do
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


## zabbix_application

zabbix_application lwrp creates application, items and triggers. You should think about items and triggers like nested
resources inside zabbix_application lwrp.

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
    <td>trends</td>
    <td>How many days store item's trends (archived history)</td>
    <td>365</td>
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

  item "vfs.fs.size[/var/log,free]" do
    type :active
    name "Free disk space on /var/log"
    frequency 600
    value_type :unsigned_int
  end

  trigger "Number #{node.fqdn} of free inodes on log < 10%" do
    expression "{#{node.fqdn}:vfs.fs.size[/var/log,free].last(0)}>0"
    severity :high
  end
end
```

## zabbix_graph

### Examples
```ruby

zabbix_graph "Graph 1" do
  width 640
  height 480
  graph_items [:key => 'vfs.fs.size[/var/log,free]', :color => '111111']
end
```

## zabbix_host

### Examples
```ruby
zabbix_host node.fqdn do
  host_group "My Favorite Host Group"
  use_ip true
  ip_address "127.0.0.1"
end
```

## zabbix_media_type

### Examples
```ruby
zabbix_media_type "sms" do
  type :sms
  modem "/dev/modem"
end
```

## zabbix_screen


### Examples
```ruby
zabbix_screen "Screen 1" do
  screen_item "Graph 1" do
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
