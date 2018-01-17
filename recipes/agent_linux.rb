extend SELinuxPolicy::Helpers
include_recipe 'selinux_policy::install' if use_selinux

selinux_policy_module 'zabbix_agent_setrlimit' do
  content <<-eos
    module zabbix_agent_setrlimit 1.0;

    require {
      type zabbix_agent_t;
      class process setrlimit;
    }

    #============= zabbix_agent_t ==============
    allow zabbix_agent_t self:process setrlimit;
  eos
  action :deploy
end

include_dir = node['zabbix']['agent']['include']
scripts_dir = node['zabbix']['agent']['scripts']

package 'zabbix-agent'

package 'zabbix-sender'

service 'zabbix-agent' do
  supports restart: true
  action [:enable, :start]
end

[include_dir, scripts_dir].each do |dir|
  directory dir do
    recursive true
    owner 'zabbix'
    group 'zabbix'
  end
end

configuration = node['zabbix']['agent']['config'].to_hash

template '/etc/zabbix/zabbix_agentd.conf' do
  source 'zabbix_agentd.conf.erb'
  owner 'zabbix'
  group 'zabbix'
  mode '0644'
  variables(configuration)
  notifies :restart, 'service[zabbix-agent]', :delayed
end
