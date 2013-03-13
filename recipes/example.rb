#
# Zabbix objects creation demo
#


cookbook_file "/tmp/zbx_templates_base_e42.xml" do
  source "zbx_templates_base_e42.xml"
  mode 0755
  owner "root"
  group "root"
end

zabbix_template "/tmp/zbx_templates_base_e42.xml" do
  action :import
end

zabbix_host node.fqdn do
  host_group "My Favorite Host Group"
  use_ip true
  ip_address "127.0.0.1"
end

zabbix_template "CPU_E42_Template"

zabbix_application "Test application" do
  action :sync

  (0..5).each do |i|
    item "vfs.fs.size[/var/log#{i},free]" do
      type :active
      name "Free disk space on /var/log#{i}"
    end
  end

  trigger "Number #{node.fqdn} of free inodes on log < 10%" do
    expression "{#{node.fqdn}:vfs.fs.size[/var/log0,free].last(0)}>0"
    severity :high
  end
end

(0..5).each do |i|
  zabbix_graph "Graph #{i}" do
    width 640
    height 480
    graph_items [:key => "vfs.fs.size[/var/log#{i},free]", :color => "#{i}" * 6]
  end
end

zabbix_screen "Screen 1" do
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

zabbix_media_type "sms" do
  type :sms
  modem "/dev/modem"
end

zabbix_user_group 'My Beloved group'

zabbix_action 'My favorite action' do
  event_source :triggers
  operation do
    user_groups 'My Beloved group'
  end

  condition :trigger, :equal, "Number #{node.fqdn} of free inodes on log < 10%"
  condition :trigger_value, :equal, :problem
  condition :trigger_severity, :gte, :high
  condition :host_group, :equal, 'My Favorite Host Group'
  condition :maintenance, :not_in, :maintenance
end

zabbix_user_macro 'my_macro' do
  value 'foobar'
end
