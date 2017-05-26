#
# Cookbook Name:: zabbix_lwrp
# Resource:: hosts
#
# Author:: LLC Express 42 (cookbooks@express42.com)
#
# Copyright (C) 2015 LLC Express 42
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
#

provides :zabbix_host
resource_name :zabbix_host

actions :create
default_action :create

attribute :type,        kind_of: Integer, default: 1
attribute :host_name,   kind_of: String,  name_attribute: true
attribute :host_group,  kind_of: [Array, String], required: true
attribute :port,        kind_of: Integer, default: 10_050
attribute :ip_address,  kind_of: String
attribute :dns,         kind_of: String
attribute :use_ip,      kind_of: [TrueClass, FalseClass], required: true, default: true

attribute :ipmi_enabled, kind_of: [TrueClass, FalseClass], default: false
attribute :snmp_enabled, kind_of: [TrueClass, FalseClass], default: false
attribute :jmx_enabled, kind_of: [TrueClass, FalseClass], default: false

attribute :ipmi_port,  kind_of: Integer, default: 623
attribute :snmp_port,  kind_of: Integer, default: 161
attribute :jmx_port,   kind_of: Integer, default: 12_345

attribute :ipmi_use_ip,     kind_of: [TrueClass, FalseClass], required: true, default: true
attribute :snmp_use_ip,     kind_of: [TrueClass, FalseClass], required: true, default: true
attribute :jmx_use_ip,      kind_of: [TrueClass, FalseClass], required: true, default: true
