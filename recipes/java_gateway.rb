
package 'zabbix-java-gateway'

node.default['zabbix']['java_gateway']['enabled'] = true

template '/etc/zabbix/zabbix_java_gateway.conf' do
  source 'zabbix_java_gateway.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables config: node['zabbix']['java_gateway']['config']
  notifies :restart, 'service[zabbix-java-gateway]', :delayed
end

service 'zabbix-java-gateway' do
  supports restart: true
  action [:enable, :start]
end
