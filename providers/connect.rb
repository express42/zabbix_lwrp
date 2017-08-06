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

use_inline_resources

provides :zabbix_connect if defined? provides

action :make do
  credentials_databag = new_resource.databag
  user = new_resource.user
  pass = new_resource.password
  apiurl = new_resource.apiurl

  if credentials_databag
    user = 'Admin'
    pass = get_data_bag_item(credentials_databag, 'admin')['pass']
  end

  raise "there aren't user and password for connection to zabbix" if !user || !pass

  chef_gem 'zabbixapi' do # ~FC009
    compile_time true if respond_to?(:compile_time)
    version node['zabbix']['api-version']
  end

  require 'zabbixapi'

  begin
    @@zbx = ZabbixApi.connect(
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
    sync_hosts if new_resource.sync
  end
end

def create_hosts
  get_hosts do |host|
    fqdn, values = host['zabbix']['hosts'].to_a.first
    next unless values

    group_ids = []
    if values['host_group'].respond_to?('each')
      values['host_group'].each do |group|
        group_ids.push(groupid: @@zbx.hostgroups.get_or_create(name: group.to_s))
      end
    else
      group = values['host_group']
      group_ids.push(groupid: @@zbx.hostgroups.get_or_create(name: group))
    end

    interfaces = [
      {
        type: 1,
        main: 1,
        ip: values['ip_address'] || '',
        dns: values['dns'] || '',
        port: values['port'],
        useip: values['use_ip'] ? 1 : 0,
      },
    ]

    if values['snmp_enabled']
      interfaces.push(
        type: 2,
        main: 1,
        ip: values['ip_address'] || '',
        dns: values['dns'] || '',
        port: values['snmp_port'],
        useip: values['snmp_use_ip'] ? 1 : 0
      )
    end

    if values['ipmi_enabled']
      interfaces.push(
        type: 3,
        main: 1,
        ip: values['ip_address'] || '',
        dns: values['dns'] || '',
        port: values['ipmi_port'],
        useip: values['ipmi_use_ip'] ? 1 : 0
      )
    end

    if values['jmx_enabled']
      interfaces.push(
        type: 4,
        main: 1,
        ip: values['ip_address'] || '',
        dns: values['dns'] || '',
        port: values['jmx_port'],
        useip: values['jmx_use_ip'] ? 1 : 0
      )
    end
    unless @@zbx.hosts.get(host: fqdn).first
      @@zbx.hosts.create(
        host: fqdn,
        interfaces: interfaces,
        groups: group_ids
      )
    end
  end
end

def create_applications
  get_hosts do |host|
    fqdn, values = host['zabbix']['hosts'].to_a.first
    tmp = @@zbx.query(
      method: 'host.get',
      params: {
        filter: {
          host: fqdn,
        },
        selectInterfaces: 'extend',
      }
    ).first
    host_id = tmp['hostid']
    interface_id = tmp['interfaces'].first['interfaceid']

    (values['applications'] || {}).each do |app_name, app_data|
      app = @@zbx.query(
        method: 'application.get',
        params: {
          hostids: host_id,
          filter: {
            name: app_name,
          },
        }
      ).first

      app_id = if app
                 app['applicationid']
               else
                 @@zbx.applications.create(hostid: host_id, name: app_name)
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
                                 applications: [app_id],
                                 trapper_hosts: host['fqdn']
            ))
          end
        else
          converge_by("Create new item #{item}") do
            @@zbx.items.create(item.to_hash.merge(
                                 hostid: host_id,
                                 interfaceid: interface_id,
                                 applications: [app_id],
                                 trapper_hosts: host['fqdn']
            ))
          end
        end
      end

      # now delete unused items
      current_items.each do |item|
        converge_by("Destroy item #{item}") { @@zbx.items.delete item['itemid'] }
      end

      # triggers' part
      app_data['triggers'].each do |_desc, trigger|
        if current_trigger = current_triggers.find { |i| i['description'] == trigger.description }
          current_triggers.delete current_trigger

          converge_by("Update #{trigger.description}") do
            @@zbx.triggers.update(trigger.to_hash.merge(triggerid: current_trigger['triggerid']))
          end
        else
          converge_by("Create #{trigger.description}") { @@zbx.triggers.create(trigger.to_hash) }
        end
      end
    end
  end
end

def create_graphs
  get_hosts do |host|
    fqdn, values = host['zabbix']['hosts'].to_a.first
    host_id = @@zbx.query(
      method: 'host.get',
      params: {
        filter: {
          host: fqdn,
        },
        selectInterfaces: 'extend',
      }
    ).first['hostid']

    (values['graphs'] || {}).each do |graph_name, graph_value|
      graph = @@zbx.query(
        method: 'graph.get',
        params: {
          hostids: host_id,
          filter: {
            name: graph_name,
          },
        }
      ).first
      next if graph
      converge_by("Create zabbix graph #{graph_name}") do
        graph_items = graph_value['gitems'].map do |gi|
          {
            itemid:    get_item_id(gi[:key], host_id),
            color:     gi[:color],
            yaxisside: gi[:yaxisside],
          }
        end

        graph = @@zbx.graphs.create(name: graph_name, height: graph_value['height'],
                                    width: graph_value['width'], gitems: graph_items,
                                    graphtype: graph_value['graphtype'])
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
        key_: key,
      },
    }
  ).first

  return item['itemid'] if item
end

def create_screens
  get_hosts do |host|
    fqdn, values = host['zabbix']['hosts'].to_a.first
    host_id = @@zbx.query(
      method: 'host.get',
      params: {
        filter: {
          host: fqdn,
        },
        selectInterfaces: 'extend',
      }
    ).first['hostid']

    (values['screens'] || []).each do |screen_name, screen_data|
      screen = @@zbx.query(
        method: 'screen.get',
        params: {
          filter: { name: screen_name },
          output: 'extend',
          selectScreenItems: 'extend',
        }
      ).first

      unless screen
        converge_by("Create zabbix screen #{screen_name}.") do
          @@zbx.screens.create(name: screen_name, hsize: screen_data['hsize'],
                               vsize: screen_data['vsize'])
          screen = @@zbx.query(
            method: 'screen.get',
            params: {
              filter: { name: screen_name },
              output: 'extend',
              selectScreenItems: 'extend',
            }
          ).first
        end
      end

      screen['screenitems'] = screen_data['screenitems'].each_with_object([]) do |item, res|
        case item['resourcetype']
        when 0 # graph resource type
          g = @@zbx.query(
            method: 'graph.get',
            params: {
              hostids: host_id,
              filter: {
                name: item['name'],
              },
            }
          ).first
          raise "Graph '#{item.name}' not found" unless g
          resource_id = g['graphid']
        else
          raise 'Incorrect resource type for screen item'
        end

        res << item.to_hash.merge(resourceid: resource_id)
      end

      screen.delete('templateid')

      @@zbx.query(
        method: 'screen.update',
        params: screen
      )
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
          host: host['fqdn'],
        },
      }
    ).first['hostid']

    (values['user_macros'] || []).each do |macro, value|
      user_macro = @@zbx.query(
        method: 'usermacro.get',
        params: {
          hostids: [host_id],
          filter: {
            macro: "{$#{macro.upcase}}",
          },
        }
      ).first

      next if user_macro
      converge_by("Create zabbix macro #{macro}.") do
        @@zbx.query(
          method: 'usermacro.create',
          params: {
            macro: "{$#{macro.upcase}}",
            hostid: host_id,
            value: value,
          }
        )
      end
    end
  end
end

# rubocop:disable Style/AccessorMethodName
def get_hosts
  if Chef::Config[:solo] || ENV['TEST_KITCHEN']
    yield node
  else
    search(:node, 'hosts:*').each do |host|
      if host['fqdn'] == node['fqdn']
        yield node
      else
        yield host
      end
    end
  end
end
# rubocop:enable Style/AccessorMethodName

def sync_hosts
  chef_hosts = []
  get_hosts do |host|
    chef_hosts << host['zabbix']['hosts'].to_a.first.first
  end

  @@zbx.query(
    method: 'host.get',
    params: {
    }
  ).each do |host|
    next if chef_hosts.include? host['host']
    @@zbx.query(
      method: 'host.delete',
      params: [
        host['hostid'],
      ]
    )
  end
end

def create_templates
  get_hosts do |host|
    _, values = host['zabbix']['hosts'].to_a.first

    (values['templates'] || []).each do |template, hostname|
      host_id = @@zbx.hosts.get_id(host: hostname)
      template = @@zbx.templates.get_id(host: template)

      next unless template
      @@zbx.templates.mass_add(
        hosts_id: [host_id],
        templates_id: [template]
      )
    end
  end
end

def create_actions
  get_hosts do |host|
    _, values = host['zabbix']['hosts'].to_a.first
    (values['actions'] || []).each do |name, data|
      filter = data['filter'].to_hash
      filter['conditions'] = data['filter']['conditions'].map do |condition|
        if condition['conditiontype'] == Chef::Resource::ZabbixLwrpAction::ZabbixCondition::TYPE[:trigger]
          value = @@zbx.triggers.get_id(description: condition['value'])
          condition.merge('value' => value)
        elsif condition['conditiontype'] == Chef::Resource::ZabbixLwrpAction::ZabbixCondition::TYPE[:host_group]
          value = @@zbx.hostgroups.get_id(name: condition['value'])
          condition.merge('value' => value)
        else
          condition
        end
      end
      operations = data['operations'].map do |operation|
        msg = operation['opmessage']
        media_type = @@zbx.mediatypes.get_id(description: msg['mediatypeid'])

        raise "Media type with name #{msg['mediatypeid']} not found" unless media_type

        if operation['opmessage_grp']
          user_groups = @@zbx.usergroups.get(name: operation['opmessage_grp'])
          operation.merge('opmessage_grp' => user_groups, 'opmessage' => msg.merge('mediatypeid' => media_type))
        else
          operation.merge('opmessage' => msg.merge('mediatypeid' => media_type))
        end
      end
      action = @@zbx.query(method: 'action.get', params: { filter: { name: name } }).first
      action_id = action['actionid'] unless action.nil?
      if action
        converge_by("Update zabbix action #{name}.") do
          @@zbx.query(
            method: 'action.update',
            params: {
              filter: filter,
              operations: operations,
              actionid: action_id,
              status: data['status'].to_s,
            }
          )
        end
      else
        converge_by("Create zabbix action #{name}.") do
          @@zbx.query(
            method: 'action.create',
            params: data.merge('filter' => filter, 'operations' => operations)
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
              updateExisting: true,
            },
            discoveryRules: {
              createMissing: true,
              updateExisting: true,
            },
            graphs: {
              createMissing: true,
              updateExisting: true,
            },
            groups: {
              createMissing: true,
            },
            hosts: {
              createMissing: true,
              updateExisting: true,
            },
            items: {
              createMissing: true,
              updateExisting: true,
            },
            templates: {
              createMissing: true,
              updateExisting: true,
            },
            templateLinkage: {
              createMissing: true,
            },
            templateScreens: {
              createMissing: true,
              updateExisting: true,
            },
            triggers: {
              createMissing: true,
              updateExisting: true,
            },
            screens: {
              createMissing: true,
              updateExisting: true,
            },
          },
          source: ::File.read(name)
        )
      end
    end
  end
end
