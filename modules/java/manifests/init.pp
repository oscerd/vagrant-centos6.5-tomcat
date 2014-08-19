# Class: java
#
# The java module allows Puppet to install Java
#
# Provides: java::setup resource definition
#
# Parameters: type, family, update_version, architecture, os, extension, tmpdir, alternative, export
# Validation:  type, family, update_version, architecture, os, extension cannot be undef
#
# java::setup { "java":
#  type => "jdk",
#  family => "7",
#  update_version => "65",
#  architecture => "x64",
#  os => "linux",
#  extension => ".tar.gz",
#  tmpdir => "",
#  alternatives => "",
#  export => ""
#  }
#
# Refer to the module README for documentation
#

class java {
}