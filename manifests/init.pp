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
  users => "yes",
  access_log => "yes",
  direct_start => "yes"
  }

tomcat::deploy { "deploy":
  war_name => "sample",
  war_versioned => "no",
  war_version => "",
  deploy_path => "/release/",
  context => "/mycontext",
  external_conf => "no",
  external_dir => "",
  external_conf_path => "",
  family => "7",
  update_version => "55",
  installdir => "/opt/",
  tmpdir => "/tmp/",
  require => Tomcat::Setup["tomcat"]
  }
