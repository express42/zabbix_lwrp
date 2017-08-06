#
# Cookbook Name:: zabbix_lwrp
# Provider:: host
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

use_inline_resources

provides :zabbix_host if defined? provides

def whyrun_supported?
  true
end

action :create do
  converge_by("Create #{new_resource}.") do
    add_data(node, new_resource.host_name,
             type:       new_resource.type,
             host_group: new_resource.host_group,
             ip_address: new_resource.ip_address,
             dns:        new_resource.dns,
             port:       new_resource.port,
             use_ip:     new_resource.use_ip)

    new_resource.jmx_enabled && add_data(node, new_resource.host_name,
                                         jmx_enabled: new_resource.jmx_enabled,
                                         jmx_port:    new_resource.jmx_port,
                                         jmx_use_ip:  new_resource.jmx_use_ip)

    new_resource.snmp_enabled && add_data(node, new_resource.host_name,
                                          snmp_enabled: new_resource.jmx_enabled,
                                          snmp_port:  new_resource.snmp_port,
                                          snmp_use_ip: new_resource.snmp_use_ip)

    new_resource.ipmi_enabled && add_data(node, new_resource.host_name,
                                          ipmi_enabled: new_resource.ipmi_enabled,
                                          ipmi_port:  new_resource.ipmi_port,
                                          ipmi_use_ip: new_resource.ipmi_use_ip)
  end
end
