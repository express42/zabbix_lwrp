#
# Zabbix client installation part
#

package "zabbix-agent" do
  action :install
end

service "zabbix-agent" do
  supports :restart => true, :reload => true
  action [ :enable, :start ]
end

# check first node attributes, if node attributes empty - try search zabbix server
if node["zabbix"]["client"]["serverip"] && !node["zabbix"]["client"]["serverip"].empty?
  zabbix_server_ip = node["zabbix"]["client"]["serverip"]
else
  if Chef::Config[:solo]
    Chef::Log.warn("This recipe uses search. Chef Solo does not support search. I will return current node")
    zabbix_node = node
  else
    zabbix_node = search(:node, "role:zabbix-server AND chef_environment:#{node.chef_environment}").first
    zabbix_node = search(:node, "role:zabbix-proxy AND chef_environment:#{node.chef_environment}").first unless zabbix_node
  end

  zabbix_server_ip = zabbix_node.ipaddress if zabbix_node
end

raise "Zabbix server ip hasn't been found! Please check configuration" if zabbix_server_ip.nil?

template "/etc/zabbix/zabbix_agentd.conf" do
  source "zabbix_agentd.conf.erb"
  variables(
    :server => zabbix_server_ip,
    :loglevel => node["zabbix"]["client"]["loglevel"],
    :include => node["zabbix"]["client"]["include"]
    )
  notifies :reload, resources(:service => "zabbix-agent")
end

cookbook_file "/tmp/rubix-0.5.16.gem" do
  source "rubix-0.5.16.gem"
end

gem_package "rubix" do
  source "/tmp/rubix-0.5.16.gem"
  action :install
  version '0.5.16'
end

ruby_block "use rubix" do
  block do
    Gem.clear_paths

    require 'rubix'

    Rubix.connect("http://#{zabbix_server_ip}/api_jsonrpc.php", 'Admin', 'zabbix')
  end
end
