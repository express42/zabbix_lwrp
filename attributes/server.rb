default['zabbix']['server']['database']['vendor'] = 'postgresql'
default['zabbix']['server']['service'] = 'zabbix-server'
default['zabbix']['server']['credentials']['databag'] = 'zabbix'
default['zabbix']['server']['templates'] = '/opt/zabbix/templates'
default['zabbix']['server']['sync_hosts'] = false

default['zabbix']['server']['config']['listenip'] = '0.0.0.0'
default['zabbix']['server']['config']['debuglevel'] = 3

default['zabbix']['server']['config']['workers'] = {
  StartPollers: 5,
  StartTrappers: 8,
  StartPingers: 1,
  StartProxyPollers: 1,
  StartDBSyncers: 4,
}

default['zabbix']['server']['config']['hk'] = {
  HousekeepingFrequency: 1,
  MaxHousekeeperDelete: 2000,
}

default['zabbix']['server']['config']['cache'] = {
  CacheSize: '24M',
  CacheUpdateFrequency: 60,
  TrendCacheSize: '24M',
  HistoryCacheSize: '8M',
  HistoryTextCacheSize: '8M',
}

default['zabbix']['server']['config']['timeouts'] = {
  Timeout: 10,
  TrapperTimeout: 100,
  UnreachablePeriod: 300,
  UnavailableDelay: 60,
  UnreachableDelay: 10,
}

default['zabbix']['server']['config']['global'] = {
}

default['zabbix']['server']['config']['java_gateway'] = {
  JavaGateway: node['zabbix']['java_gateway']['listen_ip'],
  JavaGatewayPort: node['zabbix']['java_gateway']['listen_port'],
  StartJavaPollers: node['zabbix']['java_gateway']['pollers'],
}

default['zabbix']['server']['config']['alerts'] = {
  path: '/etc/zabbix/alert.d/',
}
