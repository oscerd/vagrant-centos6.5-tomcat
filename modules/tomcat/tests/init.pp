# Just copy init.pp in your manifests directory. Place the tomcat package into /tomcat/files folder, if you select "local" mode.
# The module extract the folder and move it in a specified path. Copy sample.war into /tomcat/files folder. The sample.war package is the Apache example 
# from this url https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/ 

# Resource Default for exec
Exec {
  path => ["/bin/", "/sbin/", "/usr/bin/", "/usr/sbin/"] }

package { 'tar':
      ensure => installed
  }

package { 'unzip':
      ensure => installed
  }

tomcat::setup { "tomcat":
  family => "7",
  update_version => "55",
  extension => ".zip",
  source_mode => "local",
  installdir => "/opt/",
  tmpdir => "/tmp/",
  install_mode => "custom",
  data_source => "yes",
  users => "yes",
  access_log => "yes",
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

