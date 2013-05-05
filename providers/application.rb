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
      @app = Rubix::Application.new(:host_id => @host.id, :name => new_resource.name)
      @app.save!
    end
  end

  new_resource.items.each do |item|
    if current_item = @current_items.find { |i| i.key == item.key }
      @current_items.delete current_item

      # FIXME: update existing item
    else
      converge_by("Create new item #{item}") do
        Rubix::Item.new(item.to_hash.merge(:host_id => @host.id, :interface_id => @host.interfaces.first.id, :applications => [@app])).save!
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
    if current_trigger = @current_triggers.find { |i| i.description == trigger.description }
      @current_triggers.delete current_trigger

      # FIXME: update existing trigger
    else
      Chef::Log.info "#{trigger.to_hash} should be created"
      converge_by("Create #{trigger}") do
        Rubix::Trigger.new(trigger.to_hash).save!
      end
    end
  end

  # now delete unused triggers
  @current_triggers.each do |trigger|
    # delete only triggers not from template
    if trigger.template_id == 0
      converge_by("Distroy #{trigger}") do
        trigger.destroy
      end
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::ZabbixApplication.new(new_resource.name)

  @host = Rubix::Host.find(:name => node.fqdn)
  @app = Rubix::Application.all(:hostids => @host.id, :filter => {:name => new_resource.name}).first
  if @app.nil?
    @current_items = []
    @current_triggers = []
  else
    @current_resource.exists = true
    @current_items = Rubix::Item.all(:hostids => @host.id, :applicationids => @app.id)
    @current_triggers = Rubix::Trigger.all(:hostids => @host.id, :applicationids => @app.id)
  end
end
