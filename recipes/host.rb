#
# Cookbook Name:: zabbix_lwrp
# Recipe:: host
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

zabbix_host node['zabbix']['host']['name'] do
  action :create
  host_group    node['zabbix']['host']['group']
  use_ip        node['zabbix']['host']['agent']['use_ip']
  dns           node['zabbix']['host']['dns']
  port          node['zabbix']['agent']['config']['listen_port'] unless node['zabbix']['agent']['config']['listen_port'].to_s.empty?
  ip_address    node['zabbix']['host']['ipaddress']

  ipmi_enabled  node['zabbix']['host']['ipmi']['enabled']
  ipmi_port     node['zabbix']['host']['ipmi']['port']
  ipmi_use_ip   node['zabbix']['host']['ipmi']['use_ip']

  snmp_enabled  node['zabbix']['host']['snmp']['enabled']
  snmp_port     node['zabbix']['host']['snmp']['port']
  snmp_use_ip   node['zabbix']['host']['snmp']['use_ip']

  jmx_enabled   node['zabbix']['host']['jmx']['enabled']
  jmx_port      node['zabbix']['host']['jmx']['port']
  jmx_use_ip    node['zabbix']['host']['jmx']['use_ip']
end
