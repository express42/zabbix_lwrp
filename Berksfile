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

group :integration do
  cookbook 'locale'
  cookbook 'zabbix_lwrp_test', path: 'test/fixtures/cookbooks/zabbix_lwrp_test'
end
