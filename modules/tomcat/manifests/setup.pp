# tomcat::setup defines the setup stage of Tomcat installation
define tomcat::setup (
  $family = undef,
  $update_version = undef,
  $extension = undef,
  $source_mode = undef,
  $tmpdir = undef,
  $installdir = undef,
  $install_mode = undef,
  $data_source = undef,
  $direct_start = undef
  ) { 
  
  include tomcat::params
  include tomcat::data_source
  include tomcat::config
  
  # Validate parameters presence   
  if ($family == undef) {
    fail('family parameter must be set')
  }
  
  if ($update_version == undef) {
    fail('update version parameter must be set')
  }
  
  if ($extension == undef) {
    fail('Extension parameter must be set')
  }
  
  if ($source_mode == undef) {
    fail('mode parameter must be set')
  }
  
  if ($install_mode == undef) {
    fail('install mode parameter must be set')
  }
  
  if ($data_source == undef) {
    fail('data source parameter must be set')
  }
  
  # Validate parameters  
  
  if (($family != '6') and ($family != '7') and ($family != '8')) {
    fail('family parameter must be between "6" and "8" included')
  }

  if (($extension != ".tar.gz") and ($extension != ".zip")) {
    fail('Extension parameter must be ".tar.gz" or "zip"')
  }
  
  if (($source_mode != 'web') and ($source_mode != 'local')) {
    fail('mode parameter must have value "local" or "web"')
  }
  
  if (($install_mode != 'clean') and ($install_mode != 'custom')) {
    fail('install mode parameter must have value "clean" or "custom"')
  }
  
  if (($data_source != 'yes') and ($data_source != 'no')) {
    fail('data source parameter must have value "yes" or "no"')
  }
  
  if ($installdir == undef){
    notify{'Install folder not specified, setting default install folder /opt/':}
    $defined_installdir ='/opt/'
  } else {
    $defined_installdir = $installdir
  }
  
  if ($tmpdir == undef){
    notify{'Temp folder not specified, setting default install folder /tmp/':}
    $defined_tmpdir ='/tmp/'
  } else {
    $defined_tmpdir = $tmpdir
  }
  
  if($direct_start == undef){
    $start = "no"
  } else {
    $start = $direct_start
  }
  
  if ($extension == ".zip"){
    $extractor_command = "unzip"
    $extractor_option_source = ""
    $extractor_option_dir = "-d"
  }
  
  if ($extension == ".tar.gz"){
    $extractor_command = "tar"
    $extractor_option_source = "-xzvf"
    $extractor_option_dir = "-C"
  }
  
  $tomcat = "apache-tomcat"
  
  if ($source_mode == "local"){
  file { "${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension}":
		      ensure => present,
		      source => "puppet:///modules/tomcat/${tomcat}-${family}.0.${update_version}${extension}" }
  
  exec { 'extract_tomcat': 
          command => "${extractor_command} ${extractor_option_source} ${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension} ${extractor_option_dir} ${defined_tmpdir}",
          require => [ File[ "${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension}"],
                       Package ['tar'],
                       Package['unzip']
          ],
          unless => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}/",
          alias => extract_tomcat } 
  }
  elsif ($source_mode == "web"){ 
  $source = "http://apache.fastbull.org/tomcat/tomcat-${family}/v${family}.0.${update_version}/bin/${tomcat}-${family}.0.${update_version}${extension}"

  exec { 'retrieve_tomcat': 
          command => "wget -q ${source} -P ${defined_tmpdir}",
          unless => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}/",
          timeout => 1000 }    
          
  exec { 'extract_tomcat': 
          command => "${extractor_command} ${extractor_option_source} ${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension} ${extractor_option_dir} ${defined_tmpdir}",
          require => [ Exec[ 'retrieve_tomcat'] ], 
          alias => extract_tomcat } 
  } 
                     
  file { "$defined_installdir":
		      ensure => directory,
		      mode => '755',
		      owner => 'root', 
		      alias => tomcat_home }
  
  exec { 'move_tomcat': 
          command => "mv ${defined_tmpdir}${tomcat}-${family}.0.${update_version}/ ${defined_installdir}",
          require => [ File[ tomcat_home ], 
                       Exec[ extract_tomcat ] ],
          unless => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}/" }
  
  if ($install_mode == "custom"){   
	          file { "serverxml":
            path    => "${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::server_xml}",
            owner   => 'root',
            group   => 'root',
            require => Exec['move_tomcat'],
            mode    => '0644',
            content => template('tomcat/serverxml.erb') }
            
            file { "contextxml":
            path    => "${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::context_xml}",
            owner   => 'root',
            group   => 'root',
            require => Exec['move_tomcat'],
            mode    => '0644',
            content => template('tomcat/context.erb') }           
  }
  
  exec { 'clean_tomcat': 
        command => "rm -rf ${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension}",
        require => Exec['move_tomcat'],
        logoutput => "false" }
        
  if ($start == yes) {       
    
   exec { "make_executable":
          command => "chmod +x ${installdir}${tomcat}-${family}.0.${update_version}/bin/*.sh",
          require => Exec['move_tomcat'],
          alias => "executable" } 
    
   exec { "start_tomcat":
          command => "${installdir}${tomcat}-${family}.0.${update_version}/bin/startup.sh",
          require => [Exec[executable], Exec['move_tomcat']] }      
     }
}