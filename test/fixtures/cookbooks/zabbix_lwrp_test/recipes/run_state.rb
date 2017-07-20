# Allow testing credentials in run_state instead of databags
node.run_state['wrapper'] = {}
if node['zabbix']['server']['database']['databag'] == 'wrapper'
  node.run_state['wrapper']['databases'] = data_bag_item('zabbix', 'databases')
end

if node['zabbix']['server']['database']['mysql']['databag'] == 'wrapper'
  node.run_state['wrapper']['users'] = data_bag_item('zabbix', 'users')
end

if node['zabbix']['server']['database']['postgresql']['databag'] == 'wrapper'
  node.run_state['wrapper']['users'] = data_bag_item('zabbix', 'users')
end

if node['zabbix']['server']['credentials']['databag'] == 'wrapper'
  node.run_state['wrapper']['admin'] = data_bag_item('zabbix', 'admin')
end
