# Just copy init.pp in your manifests directory. Place the jdk o jre package into /java/files folder.
# The module extract the folder and move it in a specified path

# Resource Default for exec
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
  alternatives => "",
  export => ""
  }
