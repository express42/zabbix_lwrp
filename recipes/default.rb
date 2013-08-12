# Author:: LLC Express 42 (info@express42.com)
#
# Copyright (C) LLC 2013 Express 42
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

class Chef::Recipe
  include Express42::Base::Network
end

apt_repository "obs-zabbix" do
  action :add
  uri "http://download.opensuse.org/repositories/home:/express42:/zabbix2/precise/ ./"
  key 'http://download.opensuse.org/repositories/home:/express42:/zabbix2/precise/Release.key'
end

package "zabbix-agent" do
  action :upgrade
end

service "zabbix-agent" do
  supports :restart => true
  action [ :enable, :start ]
end

ip_mon = net_get_private(node).empty? ? net_get_public(node)[0][1] : net_get_private(node)[0][1]

directory node["zabbix"]["client"]["include"] do
  owner "zabbix"
  group "zabbix"
  recursive true
end

template "/etc/zabbix/zabbix_agentd.conf" do
  source "zabbix_agentd.conf.erb"
  variables(
    :server      => node["zabbix"]["client"]["serverhost"],
    :loglevel    => node["zabbix"]["client"]["loglevel"],
    :include     => node["zabbix"]["client"]["include"],
    :timeout     => node["zabbix"]["client"]["timeout"],
    :listen_ip   => ip_mon,
    :user_params => node["zabbix"]["client"]["user_params"]
  )
  notifies :restart, 'service[zabbix-agent]'
end
