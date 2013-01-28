package "zabbix-agent" do
  action :install
end

service "zabbix-agent" do
  supports :restart => true, :reload => true
  action [ :enable, :start ]
end

zabbix_server_ip = []

# check first node attributes, if node attributes empty - try search zabbix server
if node["zabbix"]["client"]["serverip"] && !node["zabbix"]["client"]["serverip"].empty? 
  zabbix_server_ip << node["zabbix"]["client"]["serverip"]
else 
  if Chef::Config[:solo]
    Chef::Log.warn("This recipe uses search. Chef Solo does not support search. I will return current node")
    zabbix_nodes = node
  else
    if search(:node, "role:zabbix-proxy AND chef_environment:#{node.chef_environment}").empty?
      zabbix_nodes = search(:node, "role:zabbix-server AND chef_environment:#{node.chef_environment}")
    else
      zabbix_nodes = search(:node, "role:zabbix-proxy AND chef_environment:#{node.chef_environment}")
    end
  end
  zabbix_nodes.each do |item|
    zabbix_server_ip = item["zabbix"]["server"]["ip"]
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

cookbook_file "/tmp/rubix-0.5.14.gem" do
  source "rubix-0.5.14.gem"
end

gem_package "rubix" do
  source "/tmp/rubix-0.5.14.gem"
  action :install
end

ruby_block "use rubix" do
  block do
    Gem.clear_paths

    require 'rubix'

    Rubix.connect("http://#{zabbix_server_ip}/api_jsonrpc.php", 'Admin', 'zabbix')
  end
end

cookbook_file "/tmp/zbx_templates_base_e42.xml" do
  source "zbx_templates_base_e42.xml"
  mode 0755
  owner "root"
  group "root"
end

zabbix_client_template "/tmp/zbx_templates_base_e42.xml"

zabbix_client_host node.fqdn do
  host_group "default"
  use_ip true
  ip_address "127.0.0.1"
end

zabbix_client_template "CPU_E42_Template" do
  action :add
  host_name node.fqdn
end
