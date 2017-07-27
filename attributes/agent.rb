# <> 'chocolatey' or 'bin'(zabbix binaries)
default['zabbix']['agent']['windows']['installer'] = 'chocolatey'
default['zabbix']['agent']['windows']['version'] = '3.2.0'
default['zabbix']['agent']['windows']['chocolatey']['repo'] = 'https://chocolatey.org/api/v2'
default['zabbix']['agent']['windows']['path'] = 'C:\ProgramData\zabbix'

default['zabbix']['agent']['scripts'] = case node['platform']
                                        when 'windows'
                                          "#{node['zabbix']['agent']['windows']['path']}\\scripts"
                                        else
                                          '/opt/zabbix/scripts'
                                        end
default['zabbix']['agent']['include'] = case node['platform']
                                        when 'windows'
                                          "#{node['zabbix']['agent']['windows']['path']}\\etc"
                                        else
                                          '/opt/zabbix/etc'
                                        end

default['zabbix']['agent']['config']['listen_ip'] = '0.0.0.0'
default['zabbix']['agent']['config']['listen_port'] = 10_050
default['zabbix']['agent']['config']['serverhost'] = 'localhost'
default['zabbix']['agent']['config']['hostname'] = node['fqdn']
default['zabbix']['agent']['config']['pidfile'] = '/var/run/zabbix/zabbix_agentd.pid'

default['zabbix']['agent']['config']['logs'] = {
  LogFile: case node['platform_family']
           when 'windows'
             "#{node['zabbix']['agent']['windows']['path']}\\zabbix_agentd.log"
           else
             '/var/log/zabbix/zabbix_agentd.log'
           end,
  LogFileSize: 0,
  DebugLevel: 3,
}
default['zabbix']['agent']['config']['global'] = {
  Timeout: 3,
  EnableRemoteCommands: 0,
}
default['zabbix']['agent']['config']['user_params'] = {}
