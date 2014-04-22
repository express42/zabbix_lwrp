def add_data(node, fqdn, hash)
  dm = Chef::Mixin::DeepMerge

  if node['zabbix'] && node['zabbix']['hosts'] && node['zabbix']['hosts'][fqdn]
    existing_data = node.normal['zabbix']['hosts'][fqdn]
  else
    existing_data = {}
  end

  result = dm.merge existing_data, hash

  node.normal['zabbix']['hosts'][fqdn] = result

  node.save unless Chef::Config[:solo]
end
