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
    operations = new_resource.operations.map do |op|
      op.to_hash
    end

    converge_by("Create #{new_resource}.") do
      Rubix::Action.new(
        :name     => new_resource.name,
        :event_source => new_resource.event_source,
        :escalation_time => new_resource.escalation_time,
        :enabled => new_resource.enabled,
        :message_subject => new_resource.message_subject,
        :message_body => new_resource.message_body,
        :send_recovery_message => new_resource.send_recovery_message,
        :recovery_message_subject => new_resource.recovery_message_subject,
        :recovery_message_body => new_resource.recovery_message_body,
        :operations => operations,
        :conditions => new_resource.conditions.map(&:to_hash)
        ).save
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::ZabbixAction.new(new_resource.name)

  @zabbix_action = Rubix::Action.find :name => new_resource.name

  unless @zabbix_action.nil?
    @current_resource.exists = true
  end
end
