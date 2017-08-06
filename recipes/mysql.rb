#
# Cookbook Name:: zabbix_lwrp
# Recipe:: mysql
#
# Copyright (C) LLC 2017 Express 42
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

include_recipe 'build-essential'

mysql_attr = node['zabbix']['server']['database']['mysql']

if node['platform_family'] == 'rhel'
  case mysql_attr['version']
  when '5.5'
    include_recipe 'yum-mysql-community::mysql55'
  when '5.6'
    include_recipe 'yum-mysql-community::mysql56'
  when '5.7'
    include_recipe 'yum-mysql-community::mysql57'
  end
end

mysql2_chef_gem 'default' do
  package_version mysql_attr['version']
  action :install
end

if mysql_attr['databag'].nil? ||
   mysql_attr['databag'].empty? ||
   !get_data_bag(mysql_attr['databag']).include?('users')

  raise "You should specify databag name in node['zabbix']['server']['database']['mysql']['databag'] attibute (now: #{mysql_attr['databag']}) and databag should contains key 'users'"
end

unless get_data_bag_item(mysql_attr['databag'], 'users')['users'].key?('root')
  raise 'You should specify user root in databag users'
end

unless get_data_bag_item(mysql_attr['databag'], 'users')['users'].key?('zabbix')
  raise 'You should specify user zabbix in databag users'
end

mysql_service mysql_attr['service_name'] do
  bind_address mysql_attr['configuration']['listen_addresses']
  port mysql_attr['configuration']['port']
  version mysql_attr['version']
  data_dir mysql_attr['mount_point']
  initial_root_password get_data_bag_item(mysql_attr['databag'], 'users')['users']['root']['options']['password']
  action [:create, :start]
end

# create database
db_name = mysql_attr['database_name']
db_connect_string = "mysql -h #{mysql_attr['configuration']['listen_addresses']} \
                     -P #{mysql_attr['configuration']['port']} -u root \
                     -p#{get_data_bag_item(mysql_attr['databag'], 'users')['users']['root']['options']['password']}"

execute 'Create Zabbix MySQL database' do
  command "#{db_connect_string} -e \"create database if not exists #{db_name} \
           character set #{mysql_attr['configuration']['character_set']} \
           collate #{mysql_attr['configuration']['collate']}\" "
  sensitive true
  action :run
end

# create users
get_data_bag_item(mysql_attr['databag'], 'users')['users'].each_pair do |name, options|
  execute "Create MySQL database user #{name}" do
    only_if { name != 'root' }
    command "#{db_connect_string} -e \"grant all privileges on #{db_name}.* to '#{name}'@'%' identified by '#{options['options']['password']}'; \""
    action :run
    sensitive true
  end
end
