#
# Cookbook Name:: postgresql
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

def self.zbx
  if defined?(@@zbx) && @@zbx
    @@zbx
  else
    raise 'You should put zabbix_connect resource before all zabbix resources call'
  end
end

action :make do
  credentials_databag = new_resource.databag
  user = new_resource.user
  pass = new_resource.password
  apiurl = new_resource.apiurl

  if credentials_databag
    user = "Admin"
    pass = data_bag_item(credentials_databag, 'admin')['pass'].first
  end

  raise "there aren't user and password for connection to zabbix" if !user || !pass

  chef_gem "zabbixapi" do
    version '0.5.9'
  end

  require "zabbixapi"

  @@zbx = ZabbixApi.connect(
    :url => apiurl,
    :user => user,
    :password => pass
  )
end
