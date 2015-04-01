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
