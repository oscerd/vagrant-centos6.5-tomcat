# Params related to tomcat-users file of Apache Tomcat
#
# Template: templates/users.erb

class tomcat::users{
  
  # Users
  
  # Set Default Roles
  $tomcat_roles = hiera('tomcat::roles::list')
  
  # Set Users
  $tomcat_users = hiera('tomcat::users::list')
  
  # Set Mapping users-roles
  $tomcat_map = hiera('tomcat::users::map')
  }