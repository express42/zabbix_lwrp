source 'https://supermarket.chef.io'

metadata

cookbook 'apt'
cookbook 'build-essential'
cookbook 'chef_nginx'
cookbook 'chocolatey'
cookbook 'database'
cookbook 'lvm'
cookbook 'php-fpm'
cookbook 'postgresql'
cookbook 'mysql'
cookbook 'yum-mysql-community'
cookbook 'mysql2_chef_gem'
cookbook 'yum-epel'
cookbook 'yum-scl'

group :integration do
  cookbook 'locale'
  cookbook 'zabbix_lwrp_test', path: 'test/fixtures/cookbooks/zabbix_lwrp_test'
end
