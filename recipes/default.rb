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
#    Rubix.logger.level = Logger::DEBUG
  end
end

cookbook_file "/tmp/zbx_templates_base_e42.xml" do
  source "zbx_templates_base_e42.xml"
  mode 0755
  owner "root"
  group "root"
end

zabbix_template "/tmp/zbx_templates_base_e42.xml" do
  action :import
end

zabbix_host node.fqdn do
  host_group "default"
  use_ip true
  ip_address "127.0.0.1"
end

zabbix_template "CPU_E42_Template"

zabbix_application "Test application" do
  action :sync
  item "vfs.fs.size[/var/log,free]" do
    type :active
    name "Free disk space on /var/log"
  end

=begin
 item "vfs.fs.size[#{zabbix_partition},pfree]" do
    type Float
    source :agent
    description "Free disk space on #{zabbix_partition} in %"
    units "%"
  end

  item "vfs.fs.inode[#{zabbix_partition},free]" do
    type Integer
    source :agent
    description "Free inodes on #{zabbix_partition}"
    units "bytes"
  end

  item "vfs.fs.inode[#{zabbix_partition},pfree]" do
    type Float
    source :agent
    description "Free inodes on #{zabbix_partition} in %"
    units "%"

    trigger do
      description "Number of free inodes on #{zabbix_partition} < 10%"
      value "10"
      func "max"
      relation "<"
      duration 120
      priority "High"
    end
  end

  item "vfs.fs.size[#{zabbix_partition},total]" do
    type Integer
    source :agent
    description "Total disk space on #{zabbix_partition}"
    units "bytes"
  end

  item "vfs.fs.inode[#{zabbix_partition},total]" do
    type Integer
    source :agent
    description "Total inodes on #{zabbix_partition}"
    units "bytes"
  end

  item "vfs.fs.size[#{zabbix_partition},used]" do
    type Integer
    source :agent
    description "Used disk space on #{zabbix_partition}"
    units "bytes"
  end

  item "vfs.fs.size[#{zabbix_partition},pused]" do
    type Float
    source :agent
    description "Used disk space on #{zabbix_partition} in %"
    units "%"
    trigger do
      description "Free disk space on #{zabbix_partition} < 10%"
      value "90"
      func "min"
      relation ">"
      duration 120
      priority "High"
    end
  end
=end
end
