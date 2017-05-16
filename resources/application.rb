#
# Cookbook Name:: zabbix_lwrp
# Resource:: application
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

provides :zabbix_application
resource_name :zabbix_application

actions :sync
default_action :sync

attribute :name, kind_of: String, name_attribute: true

attr_accessor :exists
attr_reader :items, :triggers

def initialize(name, run_context = nil)
  super
  @items = []
  @triggers = []
end

# Describe zabbix item
class ZabbixItem
  TYPES = {
    zabbix:      0,
    snmpv1:      1,
    trapper:     2,
    simple:      3,
    snmpv2c:     4,
    internal:    5,
    snmpv3:      6,
    active:      7,
    aggregate:   8,
    httptest:    9,
    external:    10,
    db_monitor:  11,
    ipmi:        12,
    ssh:         13,
    telnet:      14,
    calculated:  15,
  }.freeze

  VALUE_TYPES = {
    float:         0,         # Numeric (float)
    character:     1,         # Character
    log_line:      2,         # Log
    unsigned_int:  3,         # Numeric (unsigned)
    text:          4          # Text
  }.freeze

  DELTA_TYPES = {
    as_is:      0,
    speed_per_second: 1,
    delta: 2,
  }.freeze

  def initialize(key, &block)
    @key = key
    @type = TYPES[:active]
    @name = nil
    @units = ''
    @multiplier = '0'
    @delta = DELTA_TYPES[:as_is]
    @formula = ''
    @frequency = 60

    instance_eval(&block)
  end

  attr_reader :key

  def type(value)
    @type = TYPES[value]
  end

  def name(value)
    @name = value
  end

  def frequency(value)
    @frequency = value
  end

  def history(value)
    @history = value
  end

  def trends(value)
    @trends = value
  end

  def value_type(value)
    raise "Value type should be one of #{VALUE_TYPES.keys.join(', ')}" unless VALUE_TYPES.keys.include? value
    @value_type = VALUE_TYPES[value]
  end

  def units(value)
    @units = value
  end

  def multiplier(value)
    @multiplier = value
  end

  def delta(value)
    @delta = DELTA_TYPES[value]
  end

  def source(value)
    @source = value
  end

  def formula(value)
    @formula = value
  end

  def to_hash
    {
      key_:        @key,
      type:        @type,
      name:        @name,
      delay:       @frequency,
      history:     @history || 7,
      trends:      @trends || 365,
      value_type:  @value_type || VALUE_TYPES[:unsigned_int],
      delta:       @delta,
      params:      @formula,
    }
  end
end

# Describe zabbix trigger
class ZabbixTrigger
  PRIORITY = {
    not_classified: 0,
    information:    1,
    warning:        2,
    average:        3,
    high:           4,
    disaster:       5,
  }.freeze

  def initialize(description, context, &block)
    @description = description
    @context = context
    instance_eval(&block)
  end

  # it is common to use node in trigger expression, so we pass it here
  def node
    @context.node
  end

  attr_reader :description

  def expression(value)
    @expression = value
  end

  def severity(value)
    @priority = PRIORITY[value]
  end

  def to_hash
    {
      description: @description,
      expression: @expression,
      priority: @priority,
    }
  end
end

def item(name, &block)
  @items << ZabbixItem.new(name, &block)
end

def trigger(name, &block)
  @triggers << ZabbixTrigger.new(name, self, &block)
end
