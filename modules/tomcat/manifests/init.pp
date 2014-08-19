# Class: tomcat
#
# The tomcat module allows Puppet to install Apache Tomcat
#
# Provides: tomcat::setup resource definition
#
# Parameters: family, update_version, extension, mode, tmpdir, installdir
# Validation: family, update_version, extension and mode cannot be undef
#
# Example:
#	tomcat::setup { "tomcat":
#	  family => "7",
#	  update_version => "55",
#	  extension => ".zip",
#	  mode => "local",
#	  installdir => "/opt/",
#	  tmpdir => "/tmp/",
#   install_mode => "custom",
#   data_source => "yes"
#	  }
#
# Refer to the module README for documentation
#

class tomcat {
}