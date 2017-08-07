#
# Cookbook Name:: zabbix_lwrp
# Recipe:: server
#
# Copyright (C) LLC 2015-2017 Express 42
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

db_vendor = node['zabbix']['server']['database']['vendor']
unless db_vendor == 'postgresql' || db_vendor == 'mysql'
  raise "You should specify correct database vendor attribute node['zabbix']['server']['database']['vendor'] (now: #{node['zabbix']['server']['database']['vendor']})"
end

def configuration_hacks(configuration, server_version)
  configuration['cache'].delete('HistoryTextCacheSize') if server_version.to_f >= 3.0
end

sql_attr = node['zabbix']['server']['database'][db_vendor]
db_name = 'zabbix'

db_host = sql_attr['configuration']['listen_addresses']
db_port = sql_attr['configuration']['port']

# Get user and database information from data bag

if sql_attr['databag'].nil? ||
   sql_attr['databag'].empty? ||
   get_data_bag(sql_attr['databag']).empty?
  raise "You should specify databag name for zabbix db user in node['zabbix']['server']['database'][db_vendor]['databag'] attibute (now: #{sql_attr['databag']}) and databag should exist"
end

db_user_data = get_data_bag_item(sql_attr['databag'], 'users')['users']
db_user = db_vendor == 'postgresql' ? db_user_data.keys.first : 'zabbix'
db_pass = db_user_data[db_user]['options']['password']

# Generate DB config

db_config = {
  db: {
    DBName: db_name,
    DBPassword: db_pass,
    DBUser: db_user,
    DBHost: db_host,
    DBPort: db_port,
  },
}

# Install packages

case node['platform_family']
when 'debian'
  package db_vendor == 'postgresql' ? 'zabbix-server-pgsql' : 'zabbix-server-mysql' do
    response_file 'zabbix-server-withoutdb.seed'
    action [:install, :reconfig]
  end

  package 'snmp-mibs-downloader'

when 'rhel'
  package db_vendor == 'postgresql' ? 'zabbix-server-pgsql' : 'zabbix-server-mysql' do
    action [:install, :reconfig]
  end
end

zabbix_database db_name do
  db_vendor db_vendor
  db_user   db_user
  db_pass   db_pass
  db_host   db_host
  db_port   db_port
  action :create
end

directory node['zabbix']['server']['templates'] do
  recursive true
  owner 'root'
  group 'root'
end

service node['zabbix']['server']['service'] do
  supports restart: true, status: true, reload: true
  action [:enable]
end

configuration = Chef::Mixin::DeepMerge.merge(node['zabbix']['server']['config'].to_hash, db_config)

configuration_hacks(configuration, node['zabbix']['version'])

template '/etc/zabbix/zabbix_server.conf' do
  source 'zabbix-server.conf.erb'
  owner 'root'
  group 'root'
  mode '0640'
  sensitive true
  variables(configuration)
  notifies :restart, "service[#{node['zabbix']['server']['service']}]", :immediately
end
