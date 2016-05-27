#
# Cookbook Name:: zabbix_lwrp
# Recipe:: database
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

include_recipe 'postgresql_lwrp::default'

psql_attr = node['zabbix']['server']['database']['postgresql']

if psql_attr['databag'].nil? ||
   psql_attr['databag'].empty? ||
   !data_bag(psql_attr['databag']).include?('postgresql')

  raise "You should specify databag name in node['zabbix']['server']['database']['postgresql']['databag'] attibute (now: #{psql_attr['databag']}) and databag should contains key 'postgresql'"
end

cluster_name = psql_attr['cluster']

postgresql cluster_name do
  cluster_create_options 'locale' => psql_attr['locale']
  cluster_version psql_attr['version']
  configuration psql_attr['configuration']
  hba_configuration(
    [{ type: 'host', database: 'all', user: 'all', address: psql_attr['network'], method: 'md5' }]
  )
end

data_bag_item(psql_attr['databag'], 'users')['users'].each_pair do |name, options|
  postgresql_user name do
    in_cluster cluster_name
    in_version psql_attr['version']
    unencrypted_password options['options']['password']
  end
end

data_bag_item(psql_attr['databag'], 'postgresql')['databases'].each_pair do |name, options|
  postgresql_database name do
    in_cluster cluster_name
    in_version psql_attr['version']
    owner options['options']['owner']
  end
end
