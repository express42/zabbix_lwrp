default['zabbix']['server']['database']['filesystem'] = 'ext4'
default['zabbix']['server']['database']['lvm_group'] = 'shared'
default['zabbix']['server']['database']['lvm_volume'] = '/dev/sda3'
default['zabbix']['server']['database']['partition_size'] = '10G'

default['zabbix']['server']['database']['cluster'] = 'main'
default['zabbix']['server']['database']['databag'] = 'zabbix'
default['zabbix']['server']['database']['locale'] = 'en_US.utf8'
default['zabbix']['server']['database']['network'] = '127.0.0.0/8'
default['zabbix']['server']['database']['version'] = '9.4'

default['zabbix']['server']['database']['configuration']['listen_addresses'] = '127.0.0.1'
default['zabbix']['server']['database']['configuration']['port'] = '5432'
default['zabbix']['server']['database']['configuration']['max_connections'] = 300
default['zabbix']['server']['database']['configuration']['shared_buffers'] = '128MB'
default['zabbix']['server']['database']['configuration']['maintenance_work_mem'] = '128MB'
default['zabbix']['server']['database']['configuration']['work_mem'] = '8MB'
default['zabbix']['server']['database']['configuration']['effective_cache_size'] = '2GB'
default['zabbix']['server']['database']['configuration']['log_min_duration_statement'] = 1000
default['zabbix']['server']['database']['configuration']['archive_mode'] = 'on'
default['zabbix']['server']['database']['configuration']['archive_command'] = 'exit 0'
