# LWRP

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
  modem '/dev/modem'
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
