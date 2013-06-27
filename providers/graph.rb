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

def get_item_id(key, host_id)
  item = ZabbixConnect.zbx.query(
    :method => 'item.get',
    :params => {
      :hostids => host_id,
      :filter => {
        :key_ => key
      }
    }
  ).first

  return item['itemid'] if item
end

action :create do
  if ZabbixConnect.zbx
    if @current_resource.exists
      Chef::Log.info("#{new_resource} already exists")

      # FIXME update
    else
      converge_by("Create #{new_resource}") do
        graph_items = new_resource.graph_items.map do |gi|
          {
            :itemid => get_item_id(gi[:key], @host_id),
            :color   => gi[:color],
            :yaxisside => gi[:yaxisside]
          }
        end
        @graph = ZabbixConnect.zbx.graphs.create(:name => new_resource.name, :height => new_resource.height,
                                  :width => new_resource.width, :gitems => graph_items)
      end
    end
  else
    Chef::Log.warn "Zabbix connection not exists, #{new_resource} not created"
  end
end

def load_current_resource
  if ZabbixConnect.zbx
    @current_resource = Chef::Resource::ZabbixGraph.new(new_resource.name)
    @current_resource.height      new_resource.height
    @current_resource.width       new_resource.width
    @current_resource.graph_items new_resource.graph_items

    @host_id = ZabbixConnect.zbx.hosts.get_id(:host => node.fqdn)

    @graph = ZabbixConnect.zbx.query(
      :method => 'graph.get',
      :params => {
        :hostids => @host_id,
        :filter => {
          :name => new_resource.name
        }
      }
    ).first

    unless @graph.nil?
      @current_resource.exists = true
    end
  else
    Chef::Log.warn "Zabbix connection not exists, #{new_resource} not created"
  end
end
