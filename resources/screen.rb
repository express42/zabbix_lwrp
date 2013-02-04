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

attribute :name,  :kind_of => String, :name_attribute => true
attribute :hsize, :kind_of => Integer
attribute :wsize, :kind_of => Integer

attr_accessor :exists
attr_reader :screen_items

def initialize(name, run_context=nil)
  super
  @screen_items = []
end

class ZabbixScreenItem
  def initialize(name, context, &block)
    @name = name
    @context = context
    instance_eval(&block)
  end

  def name
    @name
  end

  def type
    @resource_type
  end

  def resource_type(value)
    @resource_type = value
  end
end

def screen_item(name, &block)
  @screen_items << ZabbixScreenItem.new(name, self, &block)
end
