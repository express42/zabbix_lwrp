default['zabbix']['server']['web']['server_name'] = 'localhost'
default['zabbix']['server']['web']['listen'] = '127.0.0.1'
default['zabbix']['server']['web']['port'] = '9200'

default['zabbix']['server']['web']['max_requests'] = 500
default['zabbix']['server']['web']['max_children'] = 5
default['zabbix']['server']['web']['min_spare_servers'] = 1
default['zabbix']['server']['web']['start_servers'] = 2
default['zabbix']['server']['web']['max_spare_servers'] = 3
default['zabbix']['server']['web']['process_manager'] = 'dynamic'

default['zabbix']['server']['web']['configuration']['php_admin_value[date.timezone]'] = 'UTC'
default['zabbix']['server']['web']['configuration']['php_admin_flag[display_errors]'] = false
default['zabbix']['server']['web']['configuration']['php_admin_value[error_reporting]'] = 'E_ALL &amp; ~E_DEPRECATED'
default['zabbix']['server']['web']['configuration']['php_admin_value[error_log]'] = '/var/log/zabbix-php-error.log'
default['zabbix']['server']['web']['configuration']['php_admin_value[max_execution_time]'] = '600'
default['zabbix']['server']['web']['configuration']['php_admin_value[max_input_time]'] = '300'
default['zabbix']['server']['web']['configuration']['php_admin_value[memory_limit]'] = '128M'
default['zabbix']['server']['web']['configuration']['php_admin_value[post_max_size]'] = '32M'
default['zabbix']['server']['web']['configuration']['php_admin_flag[register_globals]'] = true
default['nginx']['default_site_enabled'] = false
