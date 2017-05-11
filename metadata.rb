name             'zabbix_lwrp'
maintainer       'LLC Express 42'
maintainer_email 'cookbooks@express42.com'
license          'MIT'
description      'Installs and configures Zabbix agent and server with PostgreSQL and Nginx. Provides LWRP for creating and modifying Zabbix objects.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.1.20'
source_url       'https://github.com/express42-cookbooks/zabbix_lwrp' if respond_to?(:source_url)
issues_url       'https://github.com/express42-cookbooks/zabbix_lwrp/issues' if respond_to?(:issues_url)

depends          'apt'
depends          'build-essential'
depends          'lvm'
depends          'chef_nginx'
depends          'postgresql_lwrp'
depends          'php-fpm'
depends          'chocolatey'

recipe           'zabbix_lwrp::agent', 'Installs and configures Zabbix agent.'
recipe           'zabbix_lwrp::agent_win', 'Installs and configures Zabbix agent for Windows.'
recipe           'zabbix_lwrp::connect', 'Connects to Zabbix API to sync configuration.'
recipe           'zabbix_lwrp::default', 'Installs and configures Zabbix official repository and agent.'
recipe           'zabbix_lwrp::database', 'Installs and configures Zabbix database.'
recipe           'zabbix_lwrp::host', 'Creates host via Zabbix API.'
recipe           'zabbix_lwrp::partition', 'Configures LVM for Zabbix database.'
recipe           'zabbix_lwrp::repository', 'Installs Zabbix official repository.'
recipe           'zabbix_lwrp::server', 'Installs and configures Zabbix server.'
recipe           'zabbix_lwrp::web', 'Installs and configures Zabbix frontend.'

supports         'ubuntu'
supports         'windows'
