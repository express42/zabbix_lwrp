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

mysql_attr = node['zabbix']['server']['mysql']

# Get user and database information from data bag
if mysql_attr['databag'].nil? ||
   mysql_attr['databag'].empty? ||
   data_bag(mysql_attr['databag']).empty?
  raise "You should specify databag name for zabbix db user in node['zabbix']['server']['mysql']['databag'] attibute (now: #{mysql_attr['databag']}) and databag should exist"
end

unless data_bag_item(mysql_attr['databag'], 'mysql')['users'].key?('zabbix')
  raise 'You should specify user zabbix in databag users'
end

db_name = data_bag_item(mysql_attr['databag'], 'mysql')['database']['name']
db_host = mysql_attr['listen_addresses']
db_port = mysql_attr['port']
db_user = 'zabbix'
db_pass = data_bag_item(mysql_attr['databag'], 'mysql')['users']['zabbix']['password']

# Generate DB config
db_config = {
  db: {
    DBName: db_name,
    DBPassword: db_pass,
    DBUser: db_user,
    DBHost: db_host,
    DBPort: db_port
  }
}

# Install packages

package 'zabbix-server-mysql' do
  response_file 'zabbix-server-withoutdb.seed'
  action [:install, :reconfig]
end

package 'snmp-mibs-downloader'

zabbix_database db_name do
  db_vendor 'mysql'
  db_user db_user
  db_pass db_pass
  db_host db_host
  db_port db_port
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
