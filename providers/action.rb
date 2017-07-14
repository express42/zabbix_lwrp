#
# Cookbook Name:: zabbix_lwrp
# Provider:: action
#
# Author:: LLC Express 42 (cookbooks@express42.com)
#
# Copyright (C) 2015 LLC Express 42
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

use_inline_resources

provides :zabbix_action if defined? provides

EVENT_SOURCE = {
  triggers:          0,
  discovery:         1,
  auto_registration: 2,
}.freeze

def whyrun_supported?
  true
end

action :sync do
  converge_by("Create #{new_resource}.") do
    operations = new_resource.operations.map(&:to_hash)
    filter = new_resource.filter.to_hash

    add_data(node, node['fqdn'], 'actions' => { new_resource.name =>
      {
        name:          new_resource.name,
        eventsource:   EVENT_SOURCE[new_resource.event_source],
        esc_period:    new_resource.escalation_time,
        status:        new_resource.enabled ? 0 : 1,
        def_shortdata: new_resource.message_subject || '',
        def_longdata:  new_resource.message_body || '',
        recovery_msg:  new_resource.send_recovery_message ? 1 : 0,
        r_shortdata:   new_resource.recovery_message_subject || '',
        r_longdata:    new_resource.recovery_message_body || '',
        operations:    operations,
        filter:        filter,
      } })
  end
end
