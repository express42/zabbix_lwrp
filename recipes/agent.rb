#
# Cookbook Name:: zabbix_lwrp
# Recipe:: agent
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

package 'zabbix-agent'

package 'zabbix-sender'

service 'zabbix-agent' do
  supports restart: true
  action [:enable, :start]
end

directory node['zabbix']['agent']['include'] do
  owner 'zabbix'
  group 'zabbix'
  recursive true
end

directory node['zabbix']['agent']['scripts'] do
  owner 'zabbix'
  group 'zabbix'
  recursive true
end

directory node['zabbix']['agent']['templates'] do
  owner 'zabbix'
  group 'zabbix'
  recursive true
end

template '/etc/zabbix/zabbix_agentd.conf' do
  source 'zabbix_agentd.conf.erb'
  variables(
    server:                 node['zabbix']['agent']['serverhost'],
    loglevel:               node['zabbix']['agent']['loglevel'],
    include:                node['zabbix']['agent']['include'],
    timeout:                node['zabbix']['agent']['timeout'],
    enable_remote_commands: node['zabbix']['agent']['enable_remote_commands'],
    listen_ip:              node['zabbix']['agent']['listen_ip'],
    user_params:            node['zabbix']['agent']['user_params']
  )
  notifies :restart, 'service[zabbix-agent]', :delayed
end
