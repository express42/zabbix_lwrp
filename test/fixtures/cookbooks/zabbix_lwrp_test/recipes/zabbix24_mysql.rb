case node['platform_family']
when 'debian'
  include_recipe 'apt'
when 'rhel'
  include_recipe 'selinux_policy::install'

  # Allow phpfpm to bind to port, by giving it the http_port_t context
  selinux_policy_port node['zabbix']['server']['web']['port'] do
    protocol 'tcp'
    secontext 'http_port_t'
  end
  selinux_policy_boolean 'httpd_can_network_connect' do
    value true
  end
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
  selinux_policy_module 'zabbix_server_setrlimit' do
    content <<-eos
      module zabbix_server_setrlimit 1.0;

      require {
        type zabbix_t;
        class process setrlimit;
      }

      #============= zabbix_agent_t ==============
      allow zabbix_t self:process setrlimit;
    eos
    action :deploy
  end
end
include_recipe 'chef_nginx::default'

node.default['zabbix']['version'] = '2.4'
# Temporary use higher version of zabbixapi, for correct tests works
# In gem zabbixapi==2.4.X uses old json gem (==1.6.1) but in chefdk uses newest version
node.default['zabbix']['api-version'] = '3.0.0'
node.default['zabbix']['db_vendor'] = 'mysql'

if node['platform_version'].to_f == 16.04
  node.default['zabbix']['server']['database']['mysql']['version'] = '5.7'
end

include_recipe 'zabbix_lwrp::default'
# Create LVM partition only if exists on node (for example on Amazon is not)
if node['filesystem'].attribute?(node['zabbix']['server']['database']['postgresql']['lvm_volume'])
  include_recipe 'zabbix_lwrp::partition'
end
include_recipe 'zabbix_lwrp::database'
include_recipe 'zabbix_lwrp::server'
include_recipe 'zabbix_lwrp::web'
include_recipe 'zabbix_lwrp::host'

zabbix_application 'Test application' do
  action :sync

  (0..5).each do |i|
    item "vfs.fs.size[/var/log#{i},free]" do
      type :active
      name "Free disk space on /var/log#{i}"
    end
  end

  trigger "Number #{node['fqdn']} of free inodes on log < 10%" do
    expression "{#{node['fqdn']}:vfs.fs.size[/var/log0,free].last(0)}>0"
    severity :high
  end
end

(0..5).each do |i|
  zabbix_graph "Graph #{i}" do
    action :create
    width 640
    height 480
    graph_items [key: "vfs.fs.size[/var/log#{i},free]", color: i.to_s * 6, y_axis_side: :left]
  end
end

zabbix_screen 'Test Screen' do
  action :sync
  hsize 1
  vsize 6
  (0..5).each do |i|
    screen_item "Graph #{i}" do
      resource_type :graph
      height 200
      width 900
      y i
    end
  end
end

zabbix_media_type 'sms' do
  action :create
  type :sms
  gsm_modem '/dev/modem'
end

zabbix_user_group 'Test group' do
  action :create
end

zabbix_action 'Test action' do
  event_source :triggers
  operation do
    user_groups 'Test group'
    message do
      use_default_message false
      subject 'Test {TRIGGER.SEVERITY}: {HOSTNAME1} {TRIGGER.STATUS}: {TRIGGER.NAME}'
      message "Trigger: {TRIGGER.NAME}\n"\
        "Trigger status: {TRIGGER.STATUS}\n" \
        "Trigger severity: {TRIGGER.SEVERITY}\n" \
        "\n" \
        "Item values:\n" \
        '{ITEM.NAME1} ({HOSTNAME1}:{TRIGGER.KEY1}): {ITEM.VALUE1}'
      media_type 'sms'
    end
  end

  condition :trigger_severity, :gte, :high
  condition :host_group, :equal, 'Main'
  condition :maintenance, :not_in, :maintenance
end

zabbix_user_macro 'Test_macro' do
  action :create
  value 'foobar'
end

zabbix_host 'Test_snmp_host' do
  type 2
  host_group 'Test group'
  port 161
  use_ip true
  ip_address '127.0.0.1'
end

zabbix_template 'Linux_Template' do
  host_name 'Test_snmp_host'
end

#
# !!! This temporary hack, which starts zabbix_connect[default] as delayed action
#

# include_recipe 'zabbix_lwrp::connect'

### included recipe file recipes/connect.rb
include_recipe 'build-essential'

zabbix_connect 'default' do
  action :nothing
  apiurl 'http://localhost/api_jsonrpc.php'
  databag 'zabbix'
  sync node['zabbix']['server']['sync_hosts']
end

log "Run zabbix_connect 'default' as delayed" do
  notifies :make, 'zabbix_connect[default]', :delayed
end
### end included recipe
