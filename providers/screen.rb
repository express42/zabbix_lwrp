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
        ZabbixConnect.zbx.screens.create(:name => new_resource.name, :hsize => new_resource.hsize,
                                    :vsize => new_resource.vsize)
        @screen = ZabbixConnect.zbx.query(
          :method => 'screen.get',
          :params => {
            :filter => {:name => new_resource.name},
            :output => 'extend',
            :selectScreenItems => 'extend'}).first
      end
    end

    @host_id = ZabbixConnect.zbx.hosts.get_id(:host => node.fqdn)

    @screen['screenitems'] = new_resource.screen_items.inject([]) do |res, item|
      case item.to_hash[:resourcetype]
      when 0 # graph resource type
        g = ZabbixConnect.zbx.query(
          :method => 'graph.get',
          :params => {
            :hostids => @host_id,
            :filter => {
              :name => item.name
            }
          }
        ).first
        raise "Graph '#{item.name}' not found" unless g
        @resource_id = g["graphid"]
      else
        raise 'Incorrect resource type for screen item'
      end

      res << item.to_hash.merge(:resourceid => @resource_id)
      res
    end

    @screen.delete('templateid')

    ZabbixConnect.zbx.query(
      :method => 'screen.update',
      :params => @screen)
  else
    Chef::Log.warn "Zabbix connection not exists, #{new_resource} not created"
  end
end

def load_current_resource
  if ZabbixConnect.zbx
    @current_resource = Chef::Resource::ZabbixScreen.new(new_resource.name)

    @screen = ZabbixConnect.zbx.query(
      :method => 'screen.get',
      :params => {
        :filter => {:name => new_resource.name},
        :output => 'extend',
        :selectScreenItems => 'extend'}).first

    unless @screen.nil?
      @current_resource.exists = true
    end
  else
    Chef::Log.warn "Zabbix connection not exists, #{new_resource} not created"
  end
end
