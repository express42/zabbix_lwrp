source 'https://supermarket.chef.io'

metadata

cookbook 'apt'
cookbook 'nginx', git: 'git@github.com:evilmartians/chef-nginx.git', tag: 'v2.2.4'
cookbook 'php-fpm'
cookbook 'postgresql_lwrp'
cookbook 'build-essential', '<4.0.0'

group :integration do
  cookbook 'locale'
  cookbook 'zabbix_lwrp_test', path: 'test/fixtures/cookbooks/zabbix_lwrp_test'
end
