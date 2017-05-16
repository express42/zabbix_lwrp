default['zabbix']['agent']['include'] = '/opt/zabbix/etc'
default['zabbix']['agent']['scripts'] = '/opt/zabbix/scripts'
default['zabbix']['agent']['templates'] = '/opt/zabbix/templates'
default['zabbix']['agent']['log'] = '/var/log/zabbix/zabbix_agentd.log'
default['zabbix']['agent']['loglevel'] = 3
default['zabbix']['agent']['remotecmds'] = 0
default['zabbix']['agent']['timeout'] = 3
default['zabbix']['agent']['listen_ip'] = '0.0.0.0'
default['zabbix']['agent']['listen_port'] = 10050
default['zabbix']['agent']['enable_remote_commands'] = 0
default['zabbix']['agent']['serverhost'] = node['ipaddress']
default['zabbix']['agent']['user_params'] = {}

default['zabbix']['host_group'] = 'Hosts'

default['zabbix']['ipmi']['enabled'] = false
default['zabbix']['snmp']['enabled'] = false
default['zabbix']['jmx']['enabled'] = false
default['zabbix']['ipmi']['port'] = 623
default['zabbix']['snmp']['port'] = 161
default['zabbix']['jmx']['port'] = 12345

# <> 'chocolatey' or 'bin'(zabbix binaries)
default['zabbix']['agent']['windows']['installer'] = 'chocolatey'
default['zabbix']['agent']['windows']['version'] = '3.0.4'
default['zabbix']['agent']['windows']['chocolatey']['repo'] = 'https://chocolatey.org/api/v2'
default['zabbix']['agent']['windows']['path'] = 'C:\ProgramData\zabbix'
default['zabbix']['agent']['windows']['include'] = "#{node['zabbix']['agent']['windows']['path']}\\etc"
default['zabbix']['agent']['windows']['scripts'] = "#{node['zabbix']['agent']['windows']['path']}\\scripts"
default['zabbix']['agent']['windows']['templates'] = "#{node['zabbix']['agent']['windows']['path']}\\templates"
default['zabbix']['agent']['windows']['log'] = "#{node['zabbix']['agent']['windows']['path']}\\zabbix_agentd.log"
