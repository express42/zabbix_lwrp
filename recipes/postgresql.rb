#
# Cookbook Name:: zabbix_lwrp
# Recipe:: postgresql
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

psql_attr = node['zabbix']['server']['database']['postgresql']

node.default['postgresql']['version'] = psql_attr['version']

case node['platform_family']
when 'rhel'
  shortver = psql_attr['version'].split('.').join
  node.default['postgresql']['enable_pgdg_yum'] = true
  node.default['postgresql']['use_pgdg_packages'] = true
  node.default['postgresql']['server']['service_name'] = "postgresql-#{psql_attr['version']}"
  node.default['postgresql']['client']['packages'] = "postgresql#{shortver}-devel"
  node.default['postgresql']['server']['packages'] = ["postgresql#{shortver}-server"]
  node.default['postgresql']['contrib']['packages'] = ["postgresql#{shortver}-contrib"]

  if node['platform_version'].to_f >= 7.0
    node.default['postgresql']['setup_script'] = "postgresql#{shortver}-setup"
  end

when 'debian'
  node.default['postgresql']['enable_pgdg_apt'] = true
  node.default['postgresql']['use_pgdg_packages'] = true
  node.default['postgresql']['dir'] = "/etc/postgresql/#{psql_attr['version']}/main"
  node.default['postgresql']['client']['packages'] = ["postgresql-client-#{psql_attr['version']}", 'libpq-dev']
  node.default['postgresql']['server']['packages'] = ["postgresql-#{psql_attr['version']}"]
  node.default['postgresql']['contrib']['packages'] = ["postgresql-contrib-#{psql_attr['version']}"]
end

include_recipe 'postgresql::server'
include_recipe 'postgresql::ruby'

if psql_attr['databag'].nil? ||
   psql_attr['databag'].empty? ||
   !get_data_bag(psql_attr['databag']).include?('databases')

  raise "You should specify databag name in node['zabbix']['server']['database']['databases']['databag'] attibute (now: #{psql_attr['databag']}) and databag should contains key 'databases'"
end

node.default['postgresql']['config'] = psql_attr['configuration']
node.default['postgresql']['pg_hba'] = [{
  type: 'host',
  db: 'all',
  user: 'all',
  addr: psql_attr['network'],
  method: 'md5',
}]

postgresql_connection_info = {
  host: '127.0.0.1',
  username: 'postgres',
  password: node['postgresql']['password']['postgres'],
}

get_data_bag_item(psql_attr['databag'], 'users')['users'].each_pair do |name, options|
  postgresql_database_user name do
    connection postgresql_connection_info
    password options['options']['password']
    action :create
  end
end

get_data_bag_item(psql_attr['databag'], 'databases')['databases'].each_pair do |name, options|
  postgresql_database name do
    connection postgresql_connection_info
    owner options['options']['owner']
    action :create
  end
end
