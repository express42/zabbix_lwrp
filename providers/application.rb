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

def whyrun_supported?
  true
end

action :sync do
  if node['zabbox'] && node['zabbix']['hosts']
    app = node['zabbix']['hosts'][node.fqdn]['applications'][new_resource.name] || { items: {}, triggers: {} }
  else
    app = { items: {}, triggers: {} }
  end

  new_resource.items.each do |item|
    unless app[:items].has_key? item.key
      app[:items][item.key] = item.to_hash
    end
  end

  new_resource.triggers.each do |trigger|
    unless app[:triggers].has_key? trigger.description
      app[:triggers][trigger.description] = trigger.to_hash
    end
  end

  add_data(node, node.fqdn, {'applications' => {new_resource.name => app}})
end
