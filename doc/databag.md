# Data bag

Data bag `zabbix` must contains the following items:
* admin (with Zabbix admin password)
* databases
* users

`databases` and `users` items related to the postgresql database (see [postgresql_lwrp](https://github.com/express42-cookbooks/postgresql) cookbook)

For examples see fixture data bag `test/fixtures/databags/zabbix/`
