include_dir = node['zabbix']['agent']['include']
scripts_dir = node['zabbix']['agent']['scripts']

package 'zabbix-agent'

package 'zabbix-sender'

service 'zabbix-agent' do
  supports restart: true
  action [:enable, :start]
end

[include_dir, scripts_dir].each do |dir|
  directory dir do
    recursive true
    owner 'zabbix'
    group 'zabbix'
  end
end

configuration = node['zabbix']['agent']['config'].to_hash

template '/etc/zabbix/zabbix_agentd.conf' do
  source 'zabbix_agentd.conf.erb'
  owner 'zabbix'
  group 'zabbix'
  mode '0644'
  variables(configuration)
  notifies :restart, 'service[zabbix-agent]', :delayed
end
