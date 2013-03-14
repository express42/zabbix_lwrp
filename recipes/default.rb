# Author:: LLC Express 42 (info@express42.com)
#
# Copyright (C) LLC 2013 Express 42
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#
# Zabbix client installation part
#

class Chef::Recipe
  include Express42::Base::Network
end

apt_repository "obs-zabbix" do
  action :add
  uri "http://download.opensuse.org/repositories/home:/express42:/zabbix2/precise/ ./"
  key 'http://download.opensuse.org/repositories/home:/express42:/zabbix2/precise/Release.key'
end

package "zabbix-agent" do
  action :upgrade
end

service "zabbix-agent" do
  supports :restart => true
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

ip_mon = net_get_private(node)[0][1]

template "/etc/zabbix/zabbix_agentd.conf" do
  source "zabbix_agentd.conf.erb"
  variables(
    :server => zabbix_server_ip,
    :loglevel => node["zabbix"]["client"]["loglevel"],
    :include => node["zabbix"]["client"]["include"],
    :listen_ip => ip_mon
    )
  notifies :restart, resources(:service => "zabbix-agent")
end

cookbook_file "/tmp/rubix-0.5.21.gem" do
  source "rubix-0.5.21.gem"
end

gem_package "rubix" do
  source "/tmp/rubix-0.5.21.gem"
  action :install
  version '0.5.21'
end

ruby_block "use rubix" do
  block do
    Gem.clear_paths

    require 'rubix'

    Rubix.connect("http://#{zabbix_server_ip}/api_jsonrpc.php", 'Admin', 'zabbix')

    Rubix.logger = Logger.new STDOUT
    Rubix.logger.level = Logger::DEBUG
  end
end
