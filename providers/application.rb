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
  if ZabbixConnect.zbx

    if @current_resource.exists
      Chef::Log.info "#{new_resource} already exists."
    else
      converge_by("Create #{new_resource}.") do
        @app_id = ZabbixConnect.zbx.applications.create(:hostid => @host_id, :name => new_resource.name)
      end
    end

    @host = ZabbixConnect.zbx.query(
      :method => 'host.get',
      :params => {
        :hostids => @host_id,
        :selectInterfaces => 'refer'
      }).first

    new_resource.items.each do |item|
      if current_item = @current_items.find { |i| i["key_"] == item.key }
        @current_items.delete current_item

        converge_by("Update item #{item}") do
          ZabbixConnect.zbx.items.update(item.to_hash.merge(
            :itemid => current_item["itemid"],
            :hostid => @host_id,
            :interfaceid => @host['interfaces'].keys.first,
            :applications => [@app_id]))
        end
      else
        converge_by("Create new item #{item}") do
          ZabbixConnect.zbx.items.create(item.to_hash.merge(
            :hostid => @host_id,
            :interfaceid => @host['interfaces'].keys.first,
            :applications => [@app_id]))
        end
      end
    end

    # now delete unused items
    @current_items.each do |item|
      converge_by("Destroy item #{item}") do
        item.destroy
      end
    end

    # triggers' part
    new_resource.triggers.each do |trigger|
      if current_trigger = @current_triggers.find { |i| i["description"] == trigger.description }
        @current_triggers.delete current_trigger

        converge_by("Update #{trigger.description}") do
          ZabbixConnect.zbx.triggers.update(trigger.to_hash.merge(
            :triggerid => current_trigger["triggerid"]))
        end
      else
        converge_by("Create #{trigger.description}") do
          ZabbixConnect.zbx.triggers.create(trigger.to_hash)
        end
      end
    end

    # now delete unused triggers
    # Zabbix incorrectly select triggers that belongs to application, but all triggers depends on items
    # and deleted, when appropriate items deleted, so this is OK
  else
    Chef::Log.warn "Zabbix connection not exists, #{new_resource} not created"
  end
end

def load_current_resource
  if ZabbixConnect.zbx

    @current_resource = Chef::Resource::ZabbixApplication.new(new_resource.name)

    @host_id = ZabbixConnect.zbx.hosts.get_id(:host => node.fqdn)
    app = ZabbixConnect.zbx.query(
      :method => 'application.get',
      :params => {
        :hostids => @host_id,
        :filter => {
          :name => new_resource.name
        }
      }).first

    if app.nil?
      @current_items = []
      @current_triggers = []
    else
      @app_id = app['applicationid']
      @current_resource.exists = true
      @current_items = ZabbixConnect.zbx.query(
        :method => 'item.get',
        :params => {:hostids => @host_id, :applicationids => @app_id, :output => 'extend'}
      )

      @current_triggers = ZabbixConnect.zbx.query(
        :method => 'trigger.get',
        :params => {:hostids => @host_id, :output => 'extend'}
      )
    end
  else
    Chef::Log.warn "Zabbix connection not exists, #{new_resource} not created"
  end
end
