source 'https://supermarket.chef.io'

metadata

cookbook 'apt'
cookbook 'helpers-express42', git: 'git@github.com:express42-cookbooks/helpers-express42.git'
cookbook 'lvm'
cookbook 'nginx', git: 'git@github.com:evilmartians/chef-nginx.git', tag: 'v2.2.4'
cookbook 'php', git: 'git@github.com:express42-cookbooks/php.git'
cookbook 'postgresql_lwrp'

group :integration do
  cookbook 'locale'
  cookbook 'zabbix_lwrp_test', path: 'test/fixtures/cookbooks/zabbix_lwrp_test'
end
