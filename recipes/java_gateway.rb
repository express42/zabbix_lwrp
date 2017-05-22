
package 'zabbix-java-gateway'

node.default['zabbix']['java_gateway']['enabled'] = true

template '/etc/zabbix/zabbix_java_gateway.conf' do
  source 'zabbix_java_gateway.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    timeout:                node['zabbix']['java_gateway']['timeout'],
    listen_ip:              node['zabbix']['java_gateway']['listen_ip'],
    listen_port:            node['zabbix']['java_gateway']['listen_port'],
    pollers:                node['zabbix']['java_gateway']['pollers']
  )
  notifies :restart, 'service[zabbix-java-gateway]', :delayed
end

service 'zabbix-java-gateway' do
  supports restart: true
  action [:enable, :start]
end
