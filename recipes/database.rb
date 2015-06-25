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

include_recipe 'postgresql_lwrp::apt_official_repository'
include_recipe 'postgresql_lwrp::default'

directory node['zabbix']['server']['database']['mount_point'] do
  owner 'postgres'
  group 'postgres'
end

if node['zabbix']['server']['database']['databag'].nil? ||
   node['zabbix']['server']['database']['databag'].empty? ||
   !data_bag(node['zabbix']['server']['database']['databag']).include?('databases')

  fail "You should specify databag name in node['zabbix']['server']['database']['databag'] attibute (now: #{node['zabbix']['server']['database']['databag']}) and databag should contains key 'databases'"
end

cluster_name = node['zabbix']['server']['database']['cluster']

postgresql cluster_name do
  cluster_create_options 'locale' => node['zabbix']['server']['database']['locale']
  cluster_version node['zabbix']['server']['database']['version']
  configuration node['zabbix']['server']['database']['configuration']
  hba_configuration(
    [{ type: 'host', database: 'all', user: 'all', address: node['zabbix']['server']['database']['network'], method: 'md5' }]
  )
end

data_bag_item(node['zabbix']['server']['database']['databag'], 'users')['users'].each_pair do |name, options|
  postgresql_user name do
    in_cluster cluster_name
    in_version node['zabbix']['server']['database']['version']
    unencrypted_password options['options']['password']
  end
end

data_bag_item(node['zabbix']['server']['database']['databag'], 'databases')['databases'].each_pair do |name, options|
  postgresql_database name do
    in_cluster cluster_name
    in_version node['zabbix']['server']['database']['version']
    owner options['options']['owner']
  end
end
