def add_data(node, fqdn, hash)
  dm = Chef::Mixin::DeepMerge

  if node['zabbix'] && node['zabbix']['hosts'] && node['zabbix']['hosts'][fqdn]
    existing_data = node.default['zabbix']['hosts'][fqdn]
  else
    existing_data = {}
  end

  result = dm.merge existing_data, hash

  node.default['zabbix']['hosts'][fqdn] = result
end
