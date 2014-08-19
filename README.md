CentOS 6.5 x64 Vagrant Machine with Tomcat and Java Puppet modules
========================

Installation
-----------------

Clone this repository in a directory 

```shell
	git clone https://github.com/oscerd/vagrant-centos6.5-tomcat vagrant-centos6.5-tomcat
```

Settings
-----------------

This machine contains:

 * The following box: https://vagrantcloud.com/puppetlabs/centos-6.5-64-puppet
 * The puppet Tomcat module: https://github.com/oscerd/puppet-tomcat-module ver 1.0.1
 * The puppet Java module: https://github.com/oscerd/puppet-java-module ver 1.0.1

In the `/modules/tomcat/files` put the following files:

 * Apache Tomcat 7.0.55 (or other version) package
 * Sample War file from https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/

In the `/modules/java/files` put the following file:

 * A jdk-7u65-linux-x64.tar.gz Oracle JDK (or other version)

Manifests
-----------------

After settings let's take a look to `/manifests/init.pp`:

```puppet

	Exec {
	  path => ["/bin/", "/sbin/", "/usr/bin/", "/usr/sbin/"] }

	  package { 'tar':
	      ensure => installed
	  }

	  package { 'unzip':
	      ensure => installed
	  }

	java::setup { "java":
	  type => "jdk",
	  family => "7",
	  update_version => "65",
	  architecture => "x64",
	  os => "linux",
	  extension => ".tar.gz",
	  tmpdir => "",
	  alternatives => "yes",
	  export => "yes"
	  }

	tomcat::setup { "tomcat":
	  family => "7",
	  update_version => "55",
	  extension => ".zip",
	  source_mode => "local",
	  installdir => "/opt/",
	  tmpdir => "/tmp/",
	  install_mode => "clean",
	  data_source => "no",
	  direct_start => "yes"
	  }

	tomcat::deploy { "deploy":
	  war_name => "sample",
	  war_versioned => "no",
	  war_version => "",
	  deploy_path => "/webapps/",
	  family => "7",
	  update_version => "55",
	  installdir => "/opt/",
	  tmpdir => "/tmp/",
	  require => Tomcat::Setup["tomcat"]
	  }

```

Customize the parameters with correct values if you choose different version of Oracle JDK and/or Apache Tomcat 7.0.55

Customization
-----------------

In _hiera.yaml_ you'll see

```yaml
	---
	:backends:
	  - yaml

	:hierarchy:
	  - "data_source"
	  - "configuration"

	:yaml:
	  :datadir: '/vagrant/hiera'
```

in `/hiera/data_source.yaml` there are the parameters to customize data source:

```yaml
	---
	tomcat::data_source::ds_resource_name: jdbc/ExampleDB
	tomcat::data_source::ds_max_active: 100
	tomcat::data_source::ds_max_idle: 20
	tomcat::data_source::ds_max_wait: 10000
	tomcat::data_source::ds_username: username
	tomcat::data_source::ds_password: password
	tomcat::data_source::ds_driver_class_name: oracle.jdbc.OracleDriver
	tomcat::data_source::ds_driver: jdbc
	tomcat::data_source::ds_dbms: oracle
	tomcat::data_source::ds_host: 192.168.52.128
	tomcat::data_source::ds_port: 1521
	tomcat::data_source::ds_service: example
```

while in `/hiera/configuration.yaml` there are the parameters to customize port:

```yaml
	---
	tomcat::params::http_port: 8082
	tomcat::params::https_port: 8083
	tomcat::params::ajp_port: 8007
	tomcat::params::shutdown_port: 8001
	tomcat::params::http_connection_timeout: 20000
	tomcat::params::https_max_threads: 150
```

With the standard `/manifests/init.pp` the Tomcat installation is set to _clean_, if you choose to change it to _custom_, remember to change port forwarding properties in Vagrantfile:

```shell
	config.vm.network "forwarded_port", guest: 8082, host: 9902
```

by changing guest port from __8080__ to __8082__ as configuration.yaml defines. For more information about customization of Tomcat module see: __https://github.com/oscerd/puppet-tomcat-module__

Usage
-----------------

Now you're ready to do:

```shell
	vagrant up
```

After setting phase vagrant will start provisioning and Puppet will install Java and Tomcat. With the standard `/manifests/init.pp` Puppet will start Tomcat and deploy sample.war in /webapps/ folder

Remember
----------------- 

When Vagrant Machine will be up, from the terminal of the guest machine 

```shell
	sudo service iptables stop
```

or add in `/manifests/init.pp` the following code fragment:

```puppet
	class iptables {
	  service {'iptables':
	    ensure => stopped,
	  }
	}

	include iptables
```

otherwise you will not see anything on __http://localhost:9902/sample/__


