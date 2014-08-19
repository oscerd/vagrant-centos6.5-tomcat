# Params related to data source file of Apache Tomcat
#
# Template: templates/serverxml.erb and context.xml

class tomcat::data_source{
  
  # Datasource
  
  # Set Name
  $ds_resource_name = hiera('tomcat::data_source::ds_resource_name')

  # Set MaxActive
  $ds_max_active = hiera('tomcat::data_source::ds_max_active')
  
  # Set MaxIdle
  $ds_max_idle = hiera('tomcat::data_source::ds_max_idle')
  
  # Set MaxWait
  $ds_max_wait = hiera('tomcat::data_source::ds_max_wait')
  
  # Set username
  $ds_username = hiera('tomcat::data_source::ds_username')

  # Set password
  $ds_password = hiera('tomcat::data_source::ds_password')
  
  # Set driver class name
  $ds_driver_class_name = hiera('tomcat::data_source::ds_driver_class_name')
  
  # Url variable
  $ds_driver = hiera('tomcat::data_source::ds_driver')
  $ds_dbms = hiera('tomcat::data_source::ds_dbms')
  $ds_host = hiera('tomcat::data_source::ds_host')
  $ds_port = hiera('tomcat::data_source::ds_port')
  $ds_service = hiera('tomcat::data_source::ds_service')
  
  # Complete URL
  $ds_url = "${ds_driver}:${ds_dbms}:thin:@${ds_host}:${ds_port}/${ds_service}"
}