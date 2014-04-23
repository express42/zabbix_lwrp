#
# Cookbook Name:: zabbix-server
# Recipe:: repository
#
# Copyright 2013, Express 42 LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

apt_repository 'obs-zabbix2.2' do
  action :add
  uri 'http://obs.express42.com/project_root:/zabbix2.2/precise/ ./'
  key 'http://obs.express42.com/project_root:/zabbix2.2/precise/Release.key'
end
