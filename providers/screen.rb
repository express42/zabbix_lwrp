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
  if @current_resource.exists
    Chef::Log.info "#{new_resource} already exists."
  else
    converge_by("Create #{new_resource}.") do
      @screen = Rubix::Screen.new(:name => new_resource.name, :hsize => new_resource.hsize,
                                  :wsize => new_resource.wsize)
    end
  end

  @screen.screen_items = new_resource.screen_items.inject([]) do |res, item|

    si = {:resource_type => item.type}

    @host = Rubix::Host.find(:name => node.fqdn)
    case item.type
    when :graph
      g = Rubix::Graph.all(:filter => { :name => item.name, :hostid => @host.id }).first
      si[:resource_id] = g.id
    when :simple_graph
      i = Rubix::Item.find :key => item.name, :host_id => @host.id
      si[:resource_id] = g.id
    end

    res << Rubix::ScreenItem.new(si)
    res
  end

  @screen.save!
end

def load_current_resource
  @current_resource = Chef::Resource::ZabbixScreen.new(new_resource.name)

  @screen = Rubix::Screen.find(:name => new_resource.name)

  unless @screen.nil?
    @current_resource.exists = true
  end
end
