default['zabbix']['server']['database']['postgresql']['filesystem'] = 'ext4'
default['zabbix']['server']['database']['postgresql']['lvm_group'] = 'shared'
default['zabbix']['server']['database']['postgresql']['lvm_volume'] = '/dev/sda3'
default['zabbix']['server']['database']['postgresql']['partition_size'] = '10G'

default['zabbix']['server']['database']['postgresql']['cluster'] = 'main'
default['zabbix']['server']['database']['postgresql']['databag'] = 'zabbix'
default['zabbix']['server']['database']['postgresql']['locale'] = 'en_US.utf8'
default['zabbix']['server']['database']['postgresql']['mount_point'] = '/var/lib/postgresql'
default['zabbix']['server']['database']['postgresql']['network'] = '127.0.0.0/8'
default['zabbix']['server']['database']['postgresql']['version'] = '9.4'

default['zabbix']['server']['database']['postgresql']['configuration']['listen_addresses'] = '127.0.0.1'
default['zabbix']['server']['database']['postgresql']['configuration']['port'] = '5432'
default['zabbix']['server']['database']['postgresql']['configuration']['max_connections'] = 300
default['zabbix']['server']['database']['postgresql']['configuration']['shared_buffers'] = '128MB'
default['zabbix']['server']['database']['postgresql']['configuration']['maintenance_work_mem'] = '128MB'
default['zabbix']['server']['database']['postgresql']['configuration']['work_mem'] = '8MB'
default['zabbix']['server']['database']['postgresql']['configuration']['effective_cache_size'] = '2GB'
default['zabbix']['server']['database']['postgresql']['configuration']['log_min_duration_statement'] = 1000
default['zabbix']['server']['database']['postgresql']['configuration']['archive_mode'] = 'on'
default['zabbix']['server']['database']['postgresql']['configuration']['archive_command'] = 'exit 0'
default['zabbix']['server']['database']['postgresql']['configuration']['wal_level'] = 'archive'
