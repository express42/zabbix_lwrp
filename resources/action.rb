#
# Cookbook Name:: zabbix
# Resource:: default
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


actions :sync
default_action :sync

attr_accessor :exists
attr_reader :operations, :conditions

attribute :name, :kind_of => String, :name_attribute => true
attribute :event_source,             :required => true, :equal_to => [:triggers]
attribute :escalation_time,          :default => 60
attribute :enabled,                  :default => true
attribute :message_subject
attribute :message_body
attribute :send_recovery_message,    :default => false
attribute :recovery_message_subject
attribute :recovery_message_body

def initialize(name, run_context=nil)
  super
  @operations = []
  @conditions = []
end

def operation(&block)
  @operations << ZabbixOperation.new(self, &block)
end

def condition(*cond, &block)
  @conditions << ZabbixCondition.new(self, *cond, &block)
end

class ZabbixCondition
  TRIGGER_VALUES = { :ok => 0, :problem => 1 }.freeze
  TRIGGER_SEVERITY = {
    :info     => 1,
    :warn     => 2,
    :avg      => 3,
    :high     => 4,
    :disaster => 5  }.freeze

  def initialize(context, *cond, &block)
    if cond
      if cond.is_a?(Array) && cond.size == 3
        @type, @operation, @value = cond
      else
        raise 'condition should have 3 elements - type, operator and value'
      end
    else
      instance_eval(&block)
    end
  end

  def type value
    @type = value
  end

  def operator value
    @operator = value
  end

  def value v
    @value = v
  end

  def to_hash
    case @type
    when :trigger
      value = Rubix::Trigger.find(:description => @value).id if @value && !@value.empty?
    when :trigger_value
      raise "Only #{TRIGGER_VALUES.keys.join(' ')} is allowed for trigger value" unless TRIGGER_VALUES.has_key? @value
      value = TRIGGER_VALUES[@value]
    when :trigger_severity
      raise "Only #{TRIGGER_SEVERITY.keys.join(' ')} is allowed for trigger severity" unless TRIGGER_SEVERITY.has_key? @value
      value = TRIGGER_SEVERITY[@value]
    when :host_group
      value = Rubix::HostGroup.find(:name => @value).id if @value && !@value.empty?
    when :maintenance
      value = '0'
    else
      raise "Unknown action's condition type '#{@type}'"
    end

    {
      :type => @type,
      :operator => @operator,
      :value => value
    }
  end
end

class ZabbixOperation
  def initialize(context, &block)

    instance_eval(&block)
  end

  def type value
    @type = value
  end

  def escalation_time value
    @escalation_time = value
  end

  def start value
    @start = value
  end

  def stop value
    @stop = value
  end

  def user_groups value
    @user_groups = value
  end

  def message(&block)
    @message = ZabbixMessasge.new(&block)
  end

  def to_hash
    user_groups = Rubix::UserGroup.all(:filter => {:name => @user_groups}) if @user_groups
    {
      :type => @type || :message,
      :user_groups => user_groups
    }
  end
end

class ZabbixMessasge

  def initialize(&block)
    instance_eval(&block)
  end

  def use_default_message value
    @use_default_message = value
  end

  def subject value
    @subject = value
  end

  def message value
    @message = value
  end

  def media_type value
    @media_type = value
  end
end
