require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

describe "Zabbix Agetn" do

  it "has a running service of zabbix-agent" do
    expect(service("zabbix-agent")).to be_running
  end

end
