#
# Cookbook Name:: zabbix
# Provider:: default
#
# Author:: LLC Express 42 (info@express42.com)
#
# Copyright (C) LLC 2012 Express 42
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


action :import do
  if ZabbixConnect.zbx
    check_path = new_resource.path + '.imported'

    unless ::File.exists? check_path
      Chef::Log.info "Importing template #{new_resource.path}"
      ZabbixConnect.import_template(::File.new(new_resource.path))
      ::File.open check_path, 'w'
    end
  end
end

action :add do
  if ZabbixConnect.zbx
    if new_resource.host_name && !new_resource.host_name.blank?
      host = ZabbixConnect.zbx.hosts.get_id(:host => new_resource.host_name)
    else
      host = ZabbixConnect.zbx.hosts.get_id(:host => node.fqdn)
    end

    if host
      template = ZabbixConnect.zbx.templates.get_id(:host => new_resource.path)

      if template
        ZabbixConnect.zbx.templates.mass_add(
          :hosts_id => [host],
          :templates_id => [template]
        )
      else
        Chef::Log.info "Zabbix Template #{new_resource.path} not found"
      end
    else
      Chef::Log.info "Zabbix Host #{new_resource.host_name} not found"
    end
  else
    Chef::Log.warn "Zabbix connection not exists, #{new_resource} not created"
  end
end
