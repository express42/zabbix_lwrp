#
# Cookbook Name:: zabbix_lwrp
# Provider:: database
#
# Author:: LLC Express 42 (cookbooks@express42.com)
#
# Copyright (C) 2015-2017 LLC Express 42
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

provides :zabbix_database if defined? provides

require 'English'
require 'digest/md5'

def change_admin_password(db_connect_string)
  admin_user_pass = 'zabbix'
  # Get Admin password from data bag
  begin
    admin_user_pass = get_data_bag_item(node['zabbix']['server']['credentials']['databag'], 'admin')['pass']
  rescue
    log('Using default password for user Admin ... (pass: zabbix)')
  end
  db_vendor = new_resource.db_vendor
  cmd_key = db_vendor == 'mysql' ? '-N -B -e' : '-c'
  admin_user_pass_md5 = Digest::MD5.hexdigest(admin_user_pass)
  getdb_admin_user_pass_query = IO.popen("#{db_connect_string} #{cmd_key} \"select passwd from users where alias='Admin'\"")
  getdb_admin_user_pass = getdb_admin_user_pass_query.readlines[0].to_s.gsub(/\s+/, '')
  getdb_admin_user_pass_query.close
  if getdb_admin_user_pass != admin_user_pass_md5
    set_admin_pass_query = IO.popen("#{db_connect_string} #{cmd_key} \"update users set passwd='#{admin_user_pass_md5}' where alias = 'Admin';\"")
    set_admin_pass_query_res = set_admin_pass_query.readlines
    set_admin_pass_query.close
  end
  log('Password for web user Admin has been successfully updated.') if set_admin_pass_query_res
end

def check_zabbix_db(db_connect_string)
  db_vendor = new_resource.db_vendor
  cmd_key = db_vendor == 'mysql' ? '-N -B -e' : '-c'
  check_db_flag = false
  # Check connect to database
  log('Connect to database')
  sql_output = IO.popen("#{db_connect_string} #{cmd_key} 'SELECT 1'")
  sql_output_res = sql_output.readlines
  sql_output.close

  if $CHILD_STATUS.exitstatus.nonzero? || sql_output_res[0].to_i != 1
    log("Couldn't connect to database, please check database server configuration")
    check_db_flag = false
  else
    # Check if database exist
    check_db_exist = IO.popen("#{db_connect_string} #{cmd_key} \"select count(*) from users where alias='Admin'\"")
    check_db_exist_res = check_db_exist.readlines
    check_db_exist.close
    check_db_flag = !($CHILD_STATUS.exitstatus == 0 && check_db_exist_res[0].to_i == 1)
  end
  check_db_flag
end

action :create do
  db_vendor = new_resource.db_vendor
  db_name   = new_resource.db_name
  db_user   = new_resource.db_user
  db_pass   = new_resource.db_pass
  db_host   = new_resource.db_host
  db_port   = new_resource.db_port

  if db_vendor == 'postgresql'
    db_connect_string = "PGPASSWORD=#{db_pass} psql -q -t -h #{db_host} -p #{db_port} -U #{db_user} -d #{db_name}"

    if node['zabbix']['version'].to_f.between?(3.0, 4.0) && node['platform_family'] == 'rhel'
      db_command = "gunzip -c /usr/share/doc/zabbix-server-pgsql*/create.sql.gz | #{db_connect_string}"

    elsif node['zabbix']['version'].to_f.between?(3.0, 4.0) && node['platform_family'] == 'debian'
      db_command = "gunzip -c /usr/share/doc/zabbix-server-pgsql/create.sql.gz | #{db_connect_string}"

    elsif node['zabbix']['version'].to_f < 3.0 && node['platform_family'] == 'rhel'
      db_command = "#{db_connect_string} -f /usr/share/doc/zabbix-server-pgsql*/create/schema.sql; \
                    #{db_connect_string} -f /usr/share/doc/zabbix-server-pgsql*/create/images.sql; \
                    #{db_connect_string} -f /usr/share/doc/zabbix-server-pgsql*/create/data.sql;"

    elsif node['zabbix']['version'].to_f < 3.0 && node['platform_family'] == 'debian'
      db_command = "#{db_connect_string} -f /usr/share/zabbix-server-pgsql/schema.sql; \
                    #{db_connect_string} -f /usr/share/zabbix-server-pgsql/images.sql; \
                    #{db_connect_string} -f /usr/share/zabbix-server-pgsql/data.sql;"
    end
  elsif db_vendor == 'mysql'
    db_connect_string = "mysql -h #{db_host} -P #{db_port} -u #{db_user} -p#{db_pass} -D #{db_name}"

    if node['zabbix']['version'].to_f.between?(3.0, 4.0) && node['platform_family'] == 'rhel'
      db_command = "zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | #{db_connect_string}"

    elsif node['zabbix']['version'].to_f.between?(3.0, 4.0) && node['platform_family'] == 'debian'
      db_command = "zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | #{db_connect_string}"

    elsif node['zabbix']['version'].to_f < 3.0 && node['platform_family'] == 'rhel'
      db_command = "cat /usr/share/doc/zabbix-server-mysql*/create/schema.sql | #{db_connect_string}; \
                    cat /usr/share/doc/zabbix-server-mysql*/create/images.sql | #{db_connect_string}; \
                    cat /usr/share/doc/zabbix-server-mysql*/create/data.sql | #{db_connect_string};"

    elsif node['zabbix']['version'].to_f < 3.0 && node['platform_family'] == 'debian'
      db_command = "#{db_connect_string} < /usr/share/zabbix-server-mysql/schema.sql; \
                    #{db_connect_string} < /usr/share/zabbix-server-mysql/images.sql; \
                    #{db_connect_string} < /usr/share/zabbix-server-mysql/data.sql;"
    end
  else
    raise "You should specify correct database vendor attribute node['zabbix']['server']['database']['vendor'] (now: #{node['zabbix']['server']['database']['vendor']})"
  end

  execute 'Provisioning zabbix database' do
    command db_command
    only_if { check_zabbix_db(db_connect_string) }
    action :run
    sensitive true
  end

  ruby_block 'Set password for web user Admin' do
    block do
      change_admin_password(db_connect_string)
    end
  end

  new_resource.updated_by_last_action(true)
end
