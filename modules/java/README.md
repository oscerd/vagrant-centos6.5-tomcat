Puppet Java Module
========================

Introduction
-----------------

This module install JDK or JRE with puppet

Installation
-----------------

Clone this repository in a java directory in your puppet module directory

```shell
	git clone https://github.com/oscerd/puppet-java-module java
```

Usage
-----------------

If you include the java::setup class the module will take the package from `/java/files` folder, extract his content and move it 
in a specific directory (based on the OS we are working on). Here is an example:

```puppet
	java::setup { "java":
	  type => "jdk",
	  family => "7",
	  update_version => "65",
	  architecture => "x64",
	  os => "linux",
	  extension => ".tar.gz",
	  tmpdir => "",
	  alternatives => "",
	  export => ""
	  }
```

It's important to define a global search path for the `exec` resource to make module work. 
This should usually be placed in `manifests/site.pp`. It is also important to make sure `unzip` and `tar` command 
are installed on the target system:

```puppet
	Exec {
	  path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
	}

	package { 'tar':
	  ensure => installed
	}

	package { 'unzip':
	  ensure => installed
	}
```

Parameters
-----------------

The Puppet Java module use the following parameters in his setup

*  __Type__: Possible values of family are _jdk_ or _jre_ 
*  __Family__: Possible values of Java version _6_, _7_, _8_ 
*  __Update Version__: The update version
*  __Architecture__: The architecture related to the package. Possible values of architecture are _i586_, _x64_, _sparc_, _sparcv9_ (the last two need to be tested)
*  __Operating System__: The operating system related to the package, at this moment we support _linux_ only
*  __Extension__: The file extension, at this moment is _.tar.gz_
*  __Install Directory__: The directory where the Apache Tomcat will be installed (default is `/opt/`)
*  __Temp Directory__: The directory where the java package will be extracted (default is `/tmp/`)
*  __Alternatives__: Possible values are _yes_, _no_ and _undef_ (default is _no_). If alternatives have value _yes_, then the module will make update alternatives to set the correct path to 
java, javac and javaws (in case of type _jdk_) or only java (in case of _jre_)
*  __Export__: Possible values are _yes_, _no_ and _undef_ (default is _no_). If export is set on _yes_, then module will export new JAVA_HOME environment variable.

Testing
-----------------

The Puppet java module has been tested on the following Operating Systems: 

1. CentOS 6.5 x64
1. Debian 7.5 x64
1. Fedora 20.0 x86_64
1. Ubuntu 14.04 x64

Contributing
-----------------

Feel free to contribute by testing, opening issues and adding/changing code

Puppet Forge
-----------------

The Puppet Java Module has been published on Puppet Forge: __https://forge.puppetlabs.com/oscerd/java__

License
-----------------

Copyright 2014 Oscerd and contributors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
