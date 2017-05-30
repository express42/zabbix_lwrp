#
# Cookbook Name:: zabbix_lwrp
# Recipe:: agent_win_bin
#
# Copyright (C) LLC 2015 Express 42
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

include_dir = node['zabbix']['agent']['include']
scripts_dir = node['zabbix']['agent']['scripts']

zbx_ver = node['zabbix']['agent']['windows']['version']
zbx_path = node['zabbix']['agent']['windows']['path']

directory  "#{ENV['PROGRAMFILES']}\\Zabbix Agent" do
  recursive true
end

[include_dir, scripts_dir].each do |dir|
  directory dir do
    recursive true
  end
end

windows_zipfile "#{ENV['TEMP']}\\zabbix_agent\\#{zbx_ver}" do
  source "http://www.zabbix.com/downloads/#{zbx_ver}/zabbix_agents_#{zbx_ver}.win.zip"
  action :unzip
  not_if { ::File.exist?("#{ENV['TEMP']}\\zabbix_agent\\#{zbx_ver}\\bin") }
end

arch = '32'

arch = '64' if node['languages']['ruby']['target_cpu'] == 'x64'

configuration = node['zabbix']['agent']['config'].to_hash

template "#{zbx_path}\\zabbix_agentd.conf" do
  source 'zabbix_agentd.conf.erb'
  variables(configuration)
  notifies :restart, 'service[Zabbix Agent]', :delayed
end
#  Powershell script that checks existence of zabbix_agent binary in Program Files folder and its version
#  If binary not exists or version differents by defined one in attributes it stops agent service (if exists)
#  and copy(replace) binary files in Program Files Folder
powershell_script 'copy zbx_files' do
  code <<-EOF
  $from = "#{ENV['TEMP']}\\zabbix_agent\\#{zbx_ver}\\bin\\win#{arch}\\zabbix_*.exe"
  $to = "#{ENV['PROGRAMFILES']}\\Zabbix Agent"
  if (!((Get-Item '#{ENV['PROGRAMFILES']}\\Zabbix Agent\\zabbix_agentd.exe' -ErrorAction SilentlyContinue ).VersionInfo.FileVersion -like '#{zbx_ver}*')) {
    if (Get-Service -Name 'Zabbix Agent'  -ErrorAction SilentlyContinue)
      {
        Stop-Service 'Zabbix Agent'
      }
      Copy-Item $from $to
    }
  EOF
end

windows_package 'zabbix-agent' do
  source "#{ENV['PROGRAMFILES']}\\Zabbix Agent\\zabbix_agentd.exe"
  installer_type :custom
  options "--install --config #{zbx_path}\\zabbix_agentd.conf"
  action :install
  timeout 10
  not_if { ::Win32::Service.exists?('Zabbix Agent') }
end

service 'Zabbix Agent' do
  supports restart: true
  action [:enable, :start]
end
