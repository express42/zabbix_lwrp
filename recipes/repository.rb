#
# Cookbook Name:: zabbix_lwrp
# Recipe:: repository
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

case node['platform_family']
when 'rhel'

  os_version = node['platform_version'].split('.').first
  remote_file "#{Chef::Config[:file_cache_path]}/zabbix_repo.rpm" do
    source "http://repo.zabbix.com/zabbix/#{node['zabbix']['version']}/#{node['platform_family']}/#{os_version}/x86_64/zabbix-release-#{node['zabbix']['version']}-1.el#{os_version}.noarch.rpm"
    action :create
  end

  rpm_package 'zabbix-official' do
    source "#{Chef::Config[:file_cache_path]}/zabbix_repo.rpm"
    action :install
  end

when 'debian'

  apt_repository 'zabbix-official' do
    uri "http://repo.zabbix.com/zabbix/#{node['zabbix']['version']}/ubuntu/"
    distribution node['lsb']['codename']
    components ['main']
    key 'http://repo.zabbix.com/zabbix-official-repo.key'
  end

end
