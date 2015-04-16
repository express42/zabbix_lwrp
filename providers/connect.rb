#
# Cookbook Name:: zabbix_lwrp
# Provider:: connect
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

action :make do
  credentials_databag = new_resource.databag
  user = new_resource.user
  pass = new_resource.password
  apiurl = new_resource.apiurl

  if credentials_databag
    user = 'Admin'
    pass = data_bag_item(credentials_databag, 'admin')['pass']
  end

  fail "there aren't user and password for connection to zabbix" if !user || !pass

  chef_gem 'zabbixapi' do
    version node['zabbix']['api-version']
  end

  require 'zabbixapi'

  begin
    @@zbx = ZabbixApi.connect( # rubocop: disable ClassVars
      url:      apiurl,
      user:     user,
      password: pass
    )
  rescue Exception => e # rubocop: disable RescueException
    Chef::Log.warn "Couldn't connect to zabbix server, all zabbix provider are non-working." + e.message
  end

  if defined?(@@zbx)
    create_import_templates
    create_hosts
    create_user_macros
    create_templates
    create_applications
    create_graphs
    create_screens
    create_media_types
    create_user_groups
    create_actions
  end
end

def create_hosts
  get_hosts do |host|
    fqdn, values = host['zabbix']['hosts'].to_a.first

    group_id = @@zbx.hostgroups.get_or_create(name: values['host_group'])

    host_id = @@zbx.hosts.create_or_update(
      host: fqdn,
      interfaces: [
        {
          type: 1,
          main: 1,
          ip: values['ip_address'],
          dns: values['dns'] || '',
          port: 10_050,
          useip: values['use_ip'] ? 1 : 0
        }
      ],
      groups: [groupid: group_id]
    )

    tmp = @@zbx.query(
      method: 'host.get',
      params: {
        hostids: host_id,
        selectInterfaces: 'extend'
      }).first

    add_data(host, fqdn, 'host_id' => host_id, 'interface_id' => tmp['interfaces'].first['interfaceid'])
  end
end

def create_applications
  get_hosts do |host|
    fqdn, values = host['zabbix']['hosts'].to_a.first
    tmp = @@zbx.query(
      method: 'host.get',
      params: {
        filter: {
          host: fqdn
        },
        selectInterfaces: 'extend'
      }).first
    host_id = tmp['hostid']
    interface_id = tmp['interfaces'].first['interfaceid']

    (values['applications'] || {}).each do |app_name, app_data|
      if app_data['app_id']
        app_id = app_data['app_id']
      else
        app = @@zbx.query(
          method: 'application.get',
          params: {
            hostids: host_id,
            filter: {
              name: app_name
            }
          }
        ).first

        if app
          app_id = app['applicationid']
        else
          app_id = @@zbx.applications.create(hostid: host_id, name: app_name)
        end

        add_data(host, fqdn, 'applications' => { app_name => { 'app_id' => app_id } })
      end

      current_items = @@zbx.query(
        method: 'item.get',
        params: { hostids: host_id, applicationids: app_id, output: 'extend' }
      )

      current_triggers = @@zbx.query(
        method: 'trigger.get',
        params: { hostids: host_id, output: 'extend' }
      )

      app_data['items'].each do |key, item|
        current_item = current_items.find { |i| i['key_'] == key }
        if current_item
          current_items.delete current_item

          converge_by("Update item #{item}") do
            @@zbx.items.update(item.to_hash.merge(
                                 itemid: current_item['itemid'],
                                 hostid: host_id,
                                 interfaceid: interface_id,
                                 applications: [app_id]))
          end
        else
          converge_by("Create new item #{item}") do
            @@zbx.items.create(item.to_hash.merge(
                                 hostid: host_id,
                                 interfaceid: interface_id,
                                 applications: [app_id]))
          end
        end
      end

      # now delete unused items
      current_items.each do |item|
        converge_by("Destroy item #{item}") do
          @@zbx.items.delete item['itemid']
        end
      end

      # triggers' part
      app_data['triggers'].each do |_desc, trigger|
        if current_trigger = current_triggers.find { |i| i['description'] == trigger.description }
          current_triggers.delete current_trigger

          converge_by("Update #{trigger.description}") do
            @@zbx.triggers.update(trigger.to_hash.merge(
                                    triggerid: current_trigger['triggerid']))
          end
        else
          converge_by("Create #{trigger.description}") do
            @@zbx.triggers.create(trigger.to_hash)
          end
        end
      end
    end
  end
end

def create_graphs
  get_hosts do |host|
    _, values = host['zabbix']['hosts'].to_a.first
    host_id = values['host_id']

    (values['graphs'] || {}).each do |graph_name, graph_value|
      graph = @@zbx.query(
        method: 'graph.get',
        params: {
          hostids: host_id,
          filter: {
            name: graph_name
          }
        }
      ).first

      if graph
      else
        converge_by("Create zabbix graph #{graph_name}") do
          graph_items = graph_value['gitems'].map do |gi|
            {
              itemid:    get_item_id(gi[:key], host_id),
              color:     gi[:color],
              yaxisside: gi[:yaxisside]
            }
          end

          graph = @@zbx.graphs.create(name: graph_name, height: graph_value['height'],
                                      width: graph_value['width'], gitems: graph_items)
        end
      end
    end
  end
end

def get_item_id(key, host_id)
  item = @@zbx.query(
    method: 'item.get',
    params: {
      hostids: host_id,
      filter: {
        key_: key
      }
    }
  ).first

  return item['itemid'] if item
end

def create_screens
  get_hosts do |host|
    _, values = host['zabbix']['hosts'].to_a.first
    host_id = values['host_id']

    (values['screens'] || []).each do |screen_name, screen_data|
      screen = @@zbx.query(
        method: 'screen.get',
        params: {
          filter: { name: screen_name },
          output: 'extend',
          selectScreenItems: 'extend' }).first

      unless screen
        converge_by("Create zabbix screen #{screen_name}.") do
          @@zbx.screens.create(name: screen_name, hsize: screen_data['hsize'],
                               vsize: screen_data['vsize'])
          screen = @@zbx.query(
            method: 'screen.get',
            params: {
              filter: { name: screen_name },
              output: 'extend',
              selectScreenItems: 'extend' }).first
        end
      end

      screen['screenitems'] = screen_data['screenitems'].reduce([]) do |res, item|
        case item['resourcetype']
        when 0 # graph resource type
          g = @@zbx.query(
            method: 'graph.get',
            params: {
              hostids: host_id,
              filter: {
                name: item['name']
              }
            }
          ).first
          fail "Graph '#{item.name}' not found" unless g
          resource_id = g['graphid']
        else
          fail 'Incorrect resource type for screen item'
        end

        res << item.to_hash.merge(resourceid: resource_id)
        res
      end

      screen.delete('templateid')

      @@zbx.query(
        method: 'screen.update',
        params: screen)
    end
  end
end

def create_media_types
  get_hosts do |host|
    _, values = host['zabbix']['hosts'].to_a.first

    (values['media_types'] || []).each do |_, media_type_data|
      @@zbx.mediatypes.create_or_update(media_type_data)
    end
  end
end

def create_user_groups
  get_hosts do |host|
    _, values = host['zabbix']['hosts'].to_a.first

    (values['user_groups'] || []).each do |user_group_name|
      user_group = @@zbx.usergroups.get(name: user_group_name).first
      @@zbx.usergroups.create(name: user_group_name) unless user_group
    end
  end
end

def create_user_macros
  get_hosts do |host|
    _, values = host['zabbix']['hosts'].to_a.first
    host_id = @@zbx.query(
      method: 'host.get',
      params: {
        output: 'extend',
        filter: {
          host: host['fqdn']
        }
      }
    ).first['hostid']

    (values['user_macros'] || []).each do |macro, value|
      user_macro = @@zbx.query(
        method: 'usermacro.get',
        params: {
          hostids: [host_id],
          filter: {
            macro: "{$#{macro.upcase}}"
          }
        }
      ).first

      unless user_macro
        converge_by("Create zabbix macro #{macro}.") do
          @@zbx.query(
            method: 'usermacro.create',
            params: {
              macro: "{$#{macro.upcase}}",
              hostid: host_id,
              value: value
            }
          )
        end
      end
    end
  end
end

def get_hosts(&block)
  if Chef::Config[:solo]
    block.call node
  else
    search(:node, 'hosts:*').each do |host|
      if host['fqdn'] == node['fqdn']
        block.call node
      else
        block.call host
      end
    end
  end
end

def create_templates
  get_hosts do |host|
    _, values = host['zabbix']['hosts'].to_a.first

    (values['templates'] || []).each do |template, hostname|
      host_id = @@zbx.hosts.get_id(host: hostname)
      template = @@zbx.templates.get_id(host: template)

      if template
        @@zbx.templates.mass_add(
          hosts_id: [host_id],
          templates_id: [template]
        )
      end
    end
  end
end

def create_actions
  get_hosts do |host|
    _, values = host['zabbix']['hosts'].to_a.first

    (values['actions'] || []).each do |name, data|
      action = @@zbx.query(method: 'action.get', params: { filter: { name: name } }).first

      unless action
        conditions = data['conditions'].map do |condition|
          if condition['conditiontype'] == Chef::Resource::ZabbixLwrpAction::ZabbixLwrpCondition::TYPE[:trigger]
            value = @@zbx.triggers.get_id(description: condition['value'])
            condition.merge('value' => value)
          elsif condition['conditiontype'] == Chef::Resource::ZabbixLwrpAction::ZabbixLwrpCondition::TYPE[:host_group]
            value = @@zbx.hostgroups.get_id(name: condition['value'])
            condition.merge('value' => value)
          else
            condition
          end
        end

        operations = data['operations'].map do |operation|
          msg = operation['opmessage']
          media_type = @@zbx.mediatypes.get_id(description: msg['mediatypeid'])

          fail "Media type with name #{msg['mediatypeid']} not found" unless media_type

          if operation['opmessage_grp']
            user_groups = @@zbx.usergroups.get(name: operation['opmessage_grp'])
            operation.merge('opmessage_grp' => user_groups, 'opmessage' => msg.merge('mediatypeid' => media_type))
          else
            operation.merge('opmessage' => msg.merge('mediatypeid' => media_type))
          end
        end

        converge_by("Create zabbix action #{name}.") do
          @@zbx.query(
            method: 'action.create',
            params: data.merge('conditions' => conditions, 'operations' => operations)
          )
        end
      end
    end
  end
end

def create_import_templates
  get_hosts do |host|
    _, values = host['zabbix']['hosts'].to_a.first if host['zabbix']['hosts']

    values ||= Hash.new([])

    (values['import_templates'] || []).each do |name|
      converge_by("Import zabbix template #{name}.") do
        @@zbx.configurations.import(
          format: 'xml',
          rules: {
            applications: {
              createMissing: true,
              updateExisting: true
            },
            discoveryRules: {
              createMissing: true,
              updateExisting: true
            },
            graphs: {
              createMissing: true,
              updateExisting: true
            },
            groups: {
              createMissing: true
            },
            hosts: {
              createMissing: true,
              updateExisting: true
            },
            items: {
              createMissing: true,
              updateExisting: true
            },
            templates: {
              createMissing: true,
              updateExisting: true
            },
            templateLinkage: {
              createMissing: true
            },
            templateScreens: {
              createMissing: true,
              updateExisting: true
            },
            triggers: {
              createMissing: true,
              updateExisting: true
            },
            screens: {
              createMissing: true,
              updateExisting: true
            }
          },
          source: ::File.read(name)
        )
      end
    end
  end
end
# rubocop: enable MethodLength
