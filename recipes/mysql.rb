#
# Cookbook Name:: zabbix_lwrp
# Recipe:: mysql
#
# Copyright (C) LLC 2016 Express 42
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

mysql2_chef_gem 'default'

mysql_attr = node['zabbix']['server']['mysql']

# TODO: merge with postgresql recipe
if mysql_attr['databag'].nil? ||
   mysql_attr['databag'].empty? ||
   !data_bag(mysql_attr['databag']).include?('mysql')

  raise "You should specify databag name in node['zabbix']['server']['mysql']['databag'] attibute (now: #{mysql_attr['databag']}) and databag should contains key 'mysql'"
end

unless data_bag_item(mysql_attr['databag'], 'mysql')['users'].key?('root')
  raise 'You should specify user root in databag users'
end

unless data_bag_item(mysql_attr['databag'], 'mysql')['users'].key?('zabbix')
  raise 'You should specify user zabbix in databag users'
end

mysql_service data_bag_item(mysql_attr['databag'], 'mysql')['service']['name'] do
  bind_address mysql_attr['listen_addresses']
  port mysql_attr['port']
  version mysql_attr['version']
  data_dir node['zabbix']['server']['database']['mount_point']
  initial_root_password data_bag_item(mysql_attr['databag'], 'mysql')['users']['root']['password']
  action [:create, :start]
end

# create database
db_name = data_bag_item(mysql_attr['databag'], 'mysql')['database']['name']
db_connect_string = "mysql -h #{mysql_attr['listen_addresses']} \
                     -P #{mysql_attr['port']} -u root \
                     -p#{data_bag_item(mysql_attr['databag'], 'mysql')['users']['root']['password']}"

execute 'Create Zabbix MySQL database' do
  command "#{db_connect_string} -e \"create database if not exists #{db_name} \
           character set #{mysql_attr['character_set']} \
           collate #{mysql_attr['collate']}\" "
  action :run
end

# create users
data_bag_item(mysql_attr['databag'], 'mysql')['users'].each_pair do |name, options|
  execute "Create MySQL database user #{name}" do
    only_if { name != 'root' }
    command "#{db_connect_string} -e \"grant all privileges on #{db_name}.* to '#{name}'@'%' identified by '#{options['password']}'; \""
    action :run
  end
end
