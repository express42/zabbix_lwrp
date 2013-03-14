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

action :create do
  if @current_resource.exists
    Chef::Log.info("#{new_resource} already exists")
  else
    converge_by("Create #{new_resource}") do
      @host =  Rubix::Host.find(:name => node.fqdn)

      graph_items = new_resource.graph_items.map do |gi|
        {
          :item_id => Rubix::Item.find(:key => gi[:key], :host_id => @host.id).id,
          :color   => gi[:color],
          :y_axis_side => gi[:y_axis_side]
        }
      end
      @graph = Rubix::Graph.new(:name => new_resource.name, :height => new_resource.height,
                                :width => new_resource.width, :graph_items => graph_items)
      @graph.save!
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::ZabbixGraph.new(new_resource.name)
  @current_resource.height      new_resource.height
  @current_resource.width       new_resource.width
  @current_resource.graph_items new_resource.graph_items

  @graph = Rubix::Graph.find(:name => new_resource.name)

  unless @graph.nil?
    @current_resource.exists = true
  end
end
