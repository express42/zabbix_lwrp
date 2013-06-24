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


action :create do

  if ZabbixConnect.zbx
    group_id = ZabbixConnect.zbx.hostgroups.get_or_create(:name => new_resource.host_group)

    ZabbixConnect.zbx.hosts.create_or_update(
      :host => new_resource.host_name,
      :interfaces => [
        {
          :type => 1,
          :main => 1,
          :ip => new_resource.ip_address,
          :dns => new_resource.dns || '',
          :port => 10050,
          :useip => new_resource.use_ip ? 1 : 0
        }
      ],
      :groups => [ :groupid => group_id ]
    )
  else
    Chef::Log.warn "Zabbix connection not exists, #{new_resource} not created"
  end
end

