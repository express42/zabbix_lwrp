# Data bag

Data bag `zabbix` must contains the following items:
* admin (with Zabbix admin password)
* postgresql
* users

`postgresql` and `users` items related to the postgresql database

`users` item related to MySQL database, necessarily contains `root` and `zabbix` entries

For examples see fixture data bag `test/fixtures/databags/zabbix/`