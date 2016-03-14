#
# Cookbook Name:: zabbix_lwrp
# Provider:: application
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

provides :zabbix_application if defined? provides

def whyrun_supported?
  true
end

action :sync do
  app = if node['zabbox'] && node['zabbix']['hosts']
          node['zabbix']['hosts'][node['fqdn']]['applications'][new_resource.name] || { items: {}, triggers: {} }
        else
          { items: {}, triggers: {} }
        end

  new_resource.items.each do |item|
    app[:items][item.key] = item.to_hash unless app[:items].key? item.key
  end

  new_resource.triggers.each do |trigger|
    unless app[:triggers].key? trigger.description
      app[:triggers][trigger.description] = trigger.to_hash
    end
  end
  converge_by("Create #{new_resource}.") do
    add_data(node, node['fqdn'], 'applications' => { new_resource.name => app })
  end
end
