#
# Zabbix objects creation demo
#

zabbix_connect "zabbix" do
  apiurl "http://localhost/api_jsonrpc.php"
  user "Admin"
  password "zabbix"
end


cookbook_file "/tmp/zbx_templates_base_e42.xml" do
  source "zbx_templates_base_e42.xml"
  mode 0755
  owner "root"
  group "root"
end

zabbix_template "/tmp/zbx_templates_base_e42.xml" do
  action :import
end

zabbix_host node['fqdn'] do
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

  trigger "Number #{node['fqdn']} of free inodes on log < 10%" do
    expression "{#{node['fqdn']}:vfs.fs.size[/var/log0,free].last(0)}>0"
    severity :high
  end
end

(0..5).each do |i|
  zabbix_graph "Graph #{i}" do
    width 640
    height 480
    graph_items [:key => "vfs.fs.size[/var/log#{i},free]", :color => i.to_s * 6, :y_axis_side => :left]
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
    message do
      use_default_message false
      subject "Test {TRIGGER.SEVERITY}: {HOSTNAME1} {TRIGGER.STATUS}: {TRIGGER.NAME}"
      message "Trigger: {TRIGGER.NAME}\n"+
        "Trigger status: {TRIGGER.STATUS}\n" +
        "Trigger severity: {TRIGGER.SEVERITY}\n" +
        "\n" +
        "Item values:\n" +
        "{ITEM.NAME1} ({HOSTNAME1}:{TRIGGER.KEY1}): {ITEM.VALUE1}"
      media_type "sms"
    end
  end

  condition :trigger_severity, :gte, :high
  condition :host_group, :equal, "My Favorite Host Group"
  condition :maintenance, :not_in, :maintenance
end

zabbix_user_macro 'my_macro' do
  value 'foobar'
end
