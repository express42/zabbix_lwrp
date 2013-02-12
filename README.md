Zabbix Cookbook
======================

Install and configure zabbix-agent. Also contains a LWRP for creating all zabbix stuff like items, triggers, actions,
hosts, screens and so on.

Requirements
------------

Tested only on Ubuntu 12.04, but should works on Debian too. Works only with zabbix version 2.0.4

Attributes
----------

e.g.
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
* zabbix_action
* zabbix_application
* zabbix_graph
* zabbix_host
* zabbix_media_type
* zabbix_screen
* zabbix_template
* zabbix_user_group


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
