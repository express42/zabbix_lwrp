default['zabbix']['java_gateway']['enabled'] = false
default['zabbix']['java_gateway']['config'] = {
  TIMEOUT: 3,
  LISTEN_IP: '127.0.0.1',
  LISTEN_PORT: 10_052,
  START_POLLERS: 5,
  PID_FILE: case node['platform_family']
            when 'rhel'
              '/var/run/zabbix/zabbix_java.pid'
            when 'debian'
              '/var/run/zabbix/zabbix_java_gateway.pid'
            end,
}
