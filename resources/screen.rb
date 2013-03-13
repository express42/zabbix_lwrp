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
attribute :vsize, :kind_of => Integer

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

  def resource_type(value)
    @resource_type = value
  end

  def elements(value)
    @elements = value
  end

  def halign(value)
    @halign = value
  end

  def valign(value)
    @valign = value
  end

  def height(value)
    @height = value
  end

  def width(value)
    @width = value
  end

  def x(value)
    @x = value
  end

  def y(value)
    @y = value
  end

  def sort_triggers(value)
    @sort_triggers = value
  end

  def style(value)
    @style = value
  end

  def url(value)
    @url = value
  end

  def to_hash
    {
      :resource_type => @resource_type,
      :elements      => @elements,
      :halign        => @halign,
      :valign        => @valign,
      :height        => @height,
      :width         => @width,
      :x             => @x,
      :y             => @y,
      :sort_triggers => @sort_triggers,
      :style         => @style,
      :url           => @url
    }
  end
end

def screen_item(name, &block)
  @screen_items << ZabbixScreenItem.new(name, self, &block)
end
