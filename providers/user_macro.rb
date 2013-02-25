#
# Cookbook Name:: zabbix
# Provider:: user_macro
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
    Chef::Log.info "#{new_resource} already exists."
  else
    converge_by("Create #{new_resource}.") do
      Rubix::UserMacro.new(:name => new_resource.name, :host => @host, :value => new_resource.value).save!
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::ZabbixUserMacro.new(new_resource.name)
  host_name = new_resource.host_name || node.fqdn

  @host =  Rubix::Host.find :name => host_name

  @user_macro = Rubix::UserMacro.find :name => new_resource.name, :host_id => @host.id

  unless @user_macro.nil?
    @current_resource.exists = true
  end
end
