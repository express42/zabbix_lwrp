package "zabbix-agent" do
  action :install
end

service "zabbix-agent" do
  supports :restart => true, :reload => true
  action [ :enable, :start ]
end


if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search. I will return current node")
else
  if search(:node, "role:zabbix-proxy AND chef_environment:#{node.chef_environment}").empty?
    zabbix_nodes = search(:node, "role:zabbix-server AND chef_environment:#{node.chef_environment}")
  else
    zabbix_nodes = search(:node, "role:zabbix-proxy AND chef_environment:#{node.chef_environment}")
  end
end

if zabbix_nodes.empty?
  zabbix_server_ip = node["zabbix"]["client"]["serverip"]
else
  zabbix_nodes.each do |item|
    zabbix_server_ip << item["zabbix"]["server"]["ip"]
  end
end

raise "Zabbix server ip hasn't been found! Please check configuration" if not zabbix_server_ip

template "/etc/zabbix/zabbix_agentd.conf" do
  source "zabbix_agentd.conf.erb"
  variables(
    :server => zabbix_server_ip,
    :loglevel => node["zabbix"]["client"]["loglevel"],
    :include => node["zabbix"]["client"]["include"]
    )
  notifies :reload, resources(:service => "zabbix-agent")
end
