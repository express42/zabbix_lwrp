#
# Cookbook Name:: zabbix_lwrp
# Recipe:: database
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

node.default['postgresql']['version'] = node['zabbix']['server']['database']['version']
case node['platform_family']
when 'rhel'
  node.default['postgresql']['enable_pgdg_yum'] = true
when 'debian'
  node.default['postgresql']['enable_pgdg_apt'] = true
  node.default['postgresql']['use_pgdg_packages'] = true
  node.default['postgresql']['dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"
  node.default['postgresql']['client']['packages'] = ["postgresql-client-#{node['postgresql']['version']}", 'libpq-dev']
  node.default['postgresql']['server']['packages'] = ["postgresql-#{node['postgresql']['version']}"]
  node.default['postgresql']['contrib']['packages'] = ["postgresql-contrib-#{node['postgresql']['version']}"]
end

include_recipe 'postgresql::server'
include_recipe 'postgresql::ruby'

if node['zabbix']['server']['database']['databag'].nil? ||
   node['zabbix']['server']['database']['databag'].empty? ||
   !data_bag(node['zabbix']['server']['database']['databag']).include?('databases')

  raise "You should specify databag name in node['zabbix']['server']['database']['databag'] attibute (now: #{node['zabbix']['server']['database']['databag']}) and databag should contains key 'databases'"
end

node.default['postgresql']['config'] = node['zabbix']['server']['database']['configuration']
node.default['postgresql']['pg_hba'] = [{
  type: 'host',
  db: 'all',
  user: 'all',
  addr: node['zabbix']['server']['database']['network'],
  method: 'md5',
}]

postgresql_connection_info = {
  host: '127.0.0.1',
  username: 'postgres',
  password: node['postgresql']['password']['postgres'],
}

data_bag_item(node['zabbix']['server']['database']['databag'], 'users')['users'].each_pair do |name, options|
  postgresql_database_user name do
    connection postgresql_connection_info
    password options['options']['password']
    action :create
  end
end

data_bag_item(node['zabbix']['server']['database']['databag'], 'databases')['databases'].each_pair do |name, options|
  postgresql_database name do
    connection postgresql_connection_info
    owner options['options']['owner']
    action :create
  end
end
