default['zabbix']['server']['database']['vendor'] = 'postgresql'
default['zabbix']['server']['service'] = 'zabbix-server'
default['zabbix']['server']['credentials']['databag'] = 'zabbix'
default['zabbix']['server']['templates'] = '/opt/zabbix/templates'
default['zabbix']['server']['sync_hosts'] = false

default['zabbix']['server']['config']['listenip'] = '0.0.0.0'
default['zabbix']['server']['config']['debuglevel'] = 3

default['zabbix']['server']['config']['workers'] = {
  StartPollers: 5,
  StartTrappers: 5,
  StartPingers: 1,
  StartProxyPollers: 1,
  StartDBSyncers: 4,
}

default['zabbix']['server']['config']['hk'] = {
  HousekeepingFrequency: 1,
  MaxHousekeeperDelete: 5000,
}

default['zabbix']['server']['config']['cache'] = {
  CacheSize: '8M',
  CacheUpdateFrequency: 60,
  TrendCacheSize: '4M',
  HistoryCacheSize: '16M',
}

default['zabbix']['server']['config']['timeouts'] = {
  Timeout: 3,
  TrapperTimeout: 300,
  UnreachablePeriod: 45,
  UnavailableDelay: 60,
  UnreachableDelay: 15,
}

default['zabbix']['server']['config']['global'] = {
}

default['zabbix']['server']['config']['java_gateway'] = {
  JavaGateway: node['zabbix']['java_gateway']['config']['LISTEN_IP'],
  JavaGatewayPort: node['zabbix']['java_gateway']['config']['LISTEN_PORT'],
  StartJavaPollers: node['zabbix']['java_gateway']['config']['START_POLLERS'],
}

default['zabbix']['server']['config']['alerts'] = {
  path: '/etc/zabbix/alert.d/',
}
