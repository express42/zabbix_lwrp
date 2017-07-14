#
# Cookbook Name:: zabbix_lwrp
# Recipe:: database
#
# Copyright (C) LLC 2015-2017 Express 42
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

if node['zabbix']['server']['database']['vendor'] == 'postgresql'
  include_recipe 'zabbix_lwrp::postgresql'
elsif node['zabbix']['server']['database']['vendor'] == 'mysql'
  include_recipe 'zabbix_lwrp::mysql'
else
  raise "You should specify correct database vendor attribute node['zabbix']['server']['database']['vendor'] (now: #{node['zabbix']['server']['database']['vendor']})"
end
