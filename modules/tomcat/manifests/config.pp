# tomcat::config contains the path of all the conf/ folder file

class tomcat::config{
  $server_xml = '/conf/server.xml'
  $context_xml = '/conf/context.xml'
  $users_xml = '/conf/tomcat-users.xml'
  $context_path = '/conf/Catalina/localhost'
  $work_path_normal = '/work/Catalina/localhost/'
  $work_path_context = '/work/Catalina/localhost'
  $lib_path = '/lib/'
  $conf_path = '/conf/'
}