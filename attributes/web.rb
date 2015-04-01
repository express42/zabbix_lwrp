default['zabbix']['server']['web']['server_name'] = 'localhost'
default['zabbix']['server']['web']['listen'] = '127.0.0.1'
default['zabbix']['server']['web']['port'] = '9200'

default['zabbix']['server']['web']['limits']['core'] = 0
default['zabbix']['server']['web']['limits']['files'] = 1024
default['zabbix']['server']['web']['limits']['requests'] = 500
default['zabbix']['server']['web']['limits']['children'] = 5
default['zabbix']['server']['web']['limits']['spare_children']['min'] = 1
default['zabbix']['server']['web']['limits']['spare_children']['max'] = 3

default['zabbix']['server']['web']['configuration']['register_globals'] = true
default['zabbix']['server']['web']['configuration']['display_errors'] = false
default['zabbix']['server']['web']['configuration']['max_execution_time'] = '600'
default['zabbix']['server']['web']['configuration']['error_reporting'] = 'E_ALL &amp; ~E_DEPRECATED'
default['zabbix']['server']['web']['configuration']['date.timezone'] = 'UTC'
default['zabbix']['server']['web']['configuration']['error_log'] = '/var/log/zabbix-php-error.log'
default['zabbix']['server']['web']['configuration']['memory_limit'] = '128M'
default['zabbix']['server']['web']['configuration']['post_max_size'] = '32M'
default['zabbix']['server']['web']['configuration']['register_globals'] = true
default['zabbix']['server']['web']['configuration']['max_input_time'] = '300'
