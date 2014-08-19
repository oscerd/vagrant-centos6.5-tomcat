# Params related to conf/server.xml file of Apache Tomcat
#
# Template: templates/serverxml.erb

class tomcat::params{
  
  # Server.xml parameters
  
  # Set http port in serverxml.erb
  $http_port = hiera('tomcat::params::http_port')
  
  # Set https port in serverxml.erb
  $https_port = hiera('tomcat::params::https_port')
  
  # Set ajp port in serverxml.erb
  $ajp_port = hiera('tomcat::params::ajp_port')
  
  # Set shutdown port in serverxml.erb
  $shutdown_port = hiera('tomcat::params::shutdown_port')
  
  # Set connection timeout in http connector in serverxml.erb
  $http_connection_timeout = hiera('tomcat::params::http_connection_timeout')
  
  # Set max threads in https connector in serverxml.erb
  $https_max_threads = hiera('tomcat::params::https_max_threads')
}
