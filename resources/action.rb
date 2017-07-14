#
# Cookbook Name:: zabbix_lwrp
# Resource:: action
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

provides :zabbix_action
resource_name :zabbix_action

actions :sync
default_action :sync

attr_accessor :exists
attr_reader :operations, :filter

attribute :name, kind_of: String, name_attribute: true
attribute :event_source,             required: true, equal_to: [:triggers]
attribute :escalation_time,          default: 60
attribute :enabled,                  default: true
attribute :message_subject
attribute :message_body
attribute :send_recovery_message, default: false
attribute :recovery_message_subject
attribute :recovery_message_body

def initialize(name, run_context = nil)
  super
  @operations = []
  @filter = []
end

def operation(&block)
  @operations << ZabbixOperation.new(self, &block)
end

def condition_filter(&block)
  @filter = ZabbixFilter.new(self, &block)
end

class ZabbixFilter
  TYPE = {
    and_or: 0,
    and:    1,
    or:     2,
    formula: 3,
  }.freeze

  def initialize(_context, &block)
    @conditions = []
    instance_eval(&block)
  end

  def evaltype(value)
    @evaltype = value
  end

  def formula(value)
    @formula = value
  end

  def condition(*cond, &block)
    @conditions << ZabbixCondition.new(self, *cond, &block).to_hash
  end

  def to_hash
    {
      evaltype: TYPE[@evaltype] || 0,
      formula:  TYPE[@evaltype] == 3 ? @formula : nil,
      conditions: @conditions,
    }
  end
end

# Describe Zabbix condition in action
class ZabbixCondition
  TYPE = {
    host_group:          0,
    host:                1,
    trigger:             2,
    trigger_name:        3,
    trigger_severity:    4,
    trigger_value:       5,
    time_period:         6,
    dhost_ip:            7,
    dservice_type:       8,
    dservice_port:       9,
    dstatus:             10,
    duptime:             11,
    dvalue:              12,
    host_template:       13,
    event_acknowledged:  14,
    application:         15,
    maintenance:         16,
    node:                17,
    drule:               18,
    dcheck:              19,
    proxy:               20,
    dobject:             21,
    host_name:           22,
  }.freeze

  OPERATOR = {
    equal:       0,
    not_equal:   1,
    like:        2,
    not_like:    3,
    in:          4,
    gte:         5,
    lte:         6,
    not_in:      7,
  }.freeze

  TRIGGER_VALUES = { ok: 0, problem: 1 }.freeze
  TRIGGER_SEVERITY = {
    info:      1,
    warn:      2,
    avg:       3,
    high:      4,
    disaster:  5,
  }.freeze

  def initialize(_context, *cond, &block)
    case cond.size
    when 3
      @type, @operator, @value = cond
    when 4
      @type, @operator, @value, @formulaid = cond
    when 0
      instance_eval(&block)
    else
      raise 'condition should have 3 or 4 elements - type, operator,value, or formulaid(option)'
    end
  end

  def type(value)
    @type = value
  end

  def operator(value)
    @operator = value
  end

  def value(v)
    @value = v
  end

  def formulaid(value)
    @formulaid = value
  end

  def to_hash
    case @type
    when :trigger, :host_group
      value = @value
    when :trigger_value
      raise "Only #{TRIGGER_VALUES.keys.join(' ')} is allowed for trigger value" unless TRIGGER_VALUES.key? @value
      value = TRIGGER_VALUES[@value]
    when :trigger_severity
      raise "Only #{TRIGGER_SEVERITY.keys.join(' ')} is allowed for trigger severity" unless TRIGGER_SEVERITY.key? @value
      value = TRIGGER_SEVERITY[@value]
    when :maintenance
      value = ''
    else
      raise "Unknown action's condition type '#{@type}'"
    end
    {
      conditiontype: TYPE[@type],
      operator: OPERATOR[@operator],
      value: value,
      formulaid: @formulaid.nil? ? nil : @formulaid,
    }
  end
end

# Describe Zabbix operation in actions
class ZabbixOperation
  TYPE = {
    message:            0,
    command:            1,
    host_add:           2,
    host_remove:        3,
    host_group_add:     4,
    host_group_remove:  5,
    template_add:       6,
    template_remove:    7,
    host_enable:        8,
    host_disable:       9,
  }.freeze

  def initialize(_context, &block)
    instance_eval(&block)
  end

  def type(value)
    @type = value
  end

  def escalation_time(value)
    @escalation_time = value
  end

  def start(value)
    @start = value
  end

  def stop(value)
    @stop = value
  end

  def user_groups(value)
    @user_groups = value
  end

  def message(&block)
    @message = ZabbixMessage.new(&block)
  end

  def to_hash
    {
      operationtype:  TYPE[@type || :message],
      opmessage_grp:  @user_groups,
      opmessage:      @message.to_hash,
    }
  end
end

# Describe zabbix message in actions
class ZabbixMessage
  def initialize(&block)
    instance_eval(&block)
  end

  def use_default_message(value)
    @use_default_message = value
  end

  def subject(value)
    @subject = value
  end

  def message(value)
    @message = value
  end

  def media_type(value)
    @media_type = value
  end

  def to_hash
    {
      subject:      @subject,
      default_msg:  @use_default_message ? 1 : 0,
      message:      @message,
      mediatypeid:  @media_type,
    }
  end
end
