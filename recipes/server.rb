#
# Cookbook Name:: zabbix_lwrp
# Recipe:: server
#
# Copyright (C) LLC 2015 Express 42
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

db_name = 'zabbix'
db_node = node

# Find zabbix database address and port
if node['recipes'].include?('zabbix_lwrp::database')
  if node['zabbix']['server']['database']['configuration']['listen_addresses'] == '*' || '0.0.0.0'
    db_node_ip = '127.0.0.1'
  else
    db_node_ip = node['zabbix']['server']['database']['configuration']['listen_addresses']
  end
else
  db_node = search(:node, "recipe:zabbix_lwrp::database AND chef_environment:#{node.chef_environment}").first # ~FC003
  db_node_ip = db_node['ipaddress']
end

db_node_port = db_node['zabbix']['server']['database']['configuration']['port']

# Get user and database information from data bag

if db_node['zabbix']['server']['database']['databag'].nil? ||
   db_node['zabbix']['server']['database']['databag'].empty? ||
   data_bag(db_node['zabbix']['server']['database']['databag']).empty?
  fail "You should specify databag name for zabbix db user in node['zabbix']['server']['database']['databag'] attibute (now: #{node['zabbix']['server']['database']['databag']}) and databag should exists"
end

db_user_data = data_bag_item(db_node['zabbix']['server']['database']['databag'], 'users')['users']
db_user = db_user_data.keys.first
db_pass = db_user_data[db_user]['options']['password']

# Generate DB config

db_config = {
  db: {
    DBName: db_name,
    DBPassword: db_pass,
    DBUser: db_user,
    DBHost: db_node_ip,
    DBPort: db_node_port
  }
}

# Install packages

package 'zabbix-server-pgsql' do
  response_file 'zabbix-server-withoutdb.seed'
  action [:install, :reconfig]
end

package 'snmp-mibs-downloader'

zabbix_database db_name do
  db_user db_user
  db_pass db_pass
  db_node_ip db_node_ip
  db_node_port db_node_port
  action :create
end

service node['zabbix']['server']['service'] do
  supports restart: true, status: true, reload: true
  action [:enable]
end

template '/etc/zabbix/zabbix_server.conf' do
  source 'zabbix-server.conf.erb'
  owner 'root'
  group 'root'
  mode '0640'
  variables(node['zabbix']['server']['config'].merge(db_config).to_hash)
  notifies :restart, "service[#{node['zabbix']['server']['service']}]", :immediately
end
