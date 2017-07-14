#
# Cookbook Name:: zabbix_lwrp
# Recipe:: partition
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

include_recipe 'lvm'

db_vendor = node['zabbix']['server']['database']['vendor']

lvm_physical_volume node['zabbix']['server']['database'][db_vendor]['lvm_volume']

lvm_volume_group node['zabbix']['server']['database'][db_vendor]['lvm_group'] do
  physical_volumes node['zabbix']['server']['database'][db_vendor]['lvm_volume']
end

lvm_logical_volume 'zabbix-database' do
  group node['zabbix']['server']['database'][db_vendor]['lvm_group']
  size node['zabbix']['server']['database'][db_vendor]['partition_size']
  filesystem node['zabbix']['server']['database'][db_vendor]['filesystem']
  mount_point node['zabbix']['server']['database'][db_vendor]['mount_point']
end
