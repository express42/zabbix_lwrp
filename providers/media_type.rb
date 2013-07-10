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

TYPE = {
  :email      => 0,
  :script     => 1,
  :sms        => 2,
  :jabber     => 3,
  :ez_texting => 100
}.freeze


action :create do
  if ZabbixConnect.zbx
    if @current_resource.exists
      Chef::Log.info "#{new_resource} already exists."
    else
      converge_by("Create #{new_resource}.") do
        ZabbixConnect.zbx.mediatypes.create_or_update(
          :description => new_resource.name,
          :type        => TYPE[new_resource.type],
          :server      => new_resource.server,
          :helo        => new_resource.helo,
          :email       => new_resource.email,
          :path        => new_resource.path,
          :modem       => new_resource.modem,
          :username    => new_resource.username,
          :password    => new_resource.password
          )
      end
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::ZabbixMediaType.new(new_resource.name)

  if ZabbixConnect.zbx
    @media_type = ZabbixConnect.zbx.mediatypes.get(:description => new_resource.name).first

    unless @media_type.nil?
      @current_resource.exists = true
    end
  end
end
