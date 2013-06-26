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
  end
end

def self.import_template(file_handler)
  require 'cgi'
  require 'net/http/post/multipart'

  data = {
    'rules[groups][createMissing]'     => 1,
    'rules[host][updateExisting]'      => 1,
    'rules[host][createMissing]'       => 1,
    'rules[templates][updateExisting]' => 1,
    'rules[templates][createMissing]'  => 1,
    'rules[items][updateExisting]'     => 1,
    'rules[items][createMissing]'      => 1,
    'rules[triggers][updateExisting]'  => 1,
    'rules[triggers][createMissing]'   => 1,
    'rules[graphs][updateExisting]'    => 1,
    'rules[graphs][createMissing]'     => 1,
    :import_file                       => file_handler
  }

  path = @@zbx.client.options[:url].gsub('api_jsonrpc.php', 'conf.import.php')

  auth = @@zbx.client.instance_variable_get(:@auth_hash)

  uri = URI.parse(path)
  data = {}.tap do |wrapped|
    data.each_pair do |key, value|
      if value.respond_to?(:read)
        # We are going to assume it's always XML we're uploading.
        wrapped[key] = UploadIO.new(value, "application/xml", ::File.basename(value.path))
      else
        wrapped[key] = value
      end
    end
  end

  request = Net::HTTP::Post::Multipart.new(uri.path, data).tap do |req|
    req['Cookie'] = "zbx_sessionid=#{CGI::escape(auth)}"
  end

  Net::HTTP.new(uri.host, uri.port).request(request)
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

  chef_gem "multipart-post" do
    version '1.1.5'
  end

  require "zabbixapi"

  begin
    @@zbx = ZabbixApi.connect(
      :url => apiurl,
      :user => user,
      :password => pass
    )
  rescue
    Chef::Log.warn "Couldn't connect to zabbix server, all zabbix provider are non-working"
  end
end
