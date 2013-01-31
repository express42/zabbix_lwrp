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
#


actions :sync
default_action :sync

attribute :name, :kind_of => String, :name_attribute => true

attr_accessor :exists
attr_reader :items

def initialize(name, run_context=nil)
  super
  @items = []
end

class ZabbixItem
  def initialize(key, context, &block)
    @key = key
    @type = Integer
    @name = nil
    @units = ''
    @multiplier = '0'
    @delta = '0'
    @formula = ''
    @source = :trapper
    @context = context

    instance_eval(&block)
  end

  def get_key
    @key
  end

  def type(value)
    @type = value
  end

  def name(value)
    @name = value
  end

  def units(value)
    @units = value
  end

  def multiplier(value)
    @multiplier = value
  end

  def delta(value)
    @delta = value
  end

  def source(value)
    @source = value
  end

  def formula(value)
    @formula = value
  end

  def trigger(&block)
    trigger = ZabbixTrigger.new(&block)
    trigger.item @name

    @context.triggers << trigger
  end

  def to_hash
    {
      :key => @key,
      :type => @type,
      :name => @name
    }
  end
end

def item(name, &block)
  @items << ZabbixItem.new(name, self, &block)
end
