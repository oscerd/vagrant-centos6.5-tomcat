# tomcat::setup defines the deploy stage of Tomcat installation
define tomcat::deploy (
  $war_name           = undef,
  $war_versioned      = undef,
  $war_version        = undef,
  $deploy_path        = undef,
  $context            = undef,
  $symbolic_link      = undef,
  $external_conf      = undef,
  $external_dir       = undef,
  $external_conf_path = undef,
  $family             = undef,
  $update_version     = undef,
  $installdir         = undef,
  $tmpdir             = undef,
  $hot_deploy         = undef,
  $as_service         = undef,
  $direct_restart     = undef) {
  $extension = ".war"
  $tomcat = "apache-tomcat"
  $default_deploy = "/webapps/"

  # Validate parameters presence
  if ($war_name == undef) {
    fail('war name parameter must be set')
  }

  if ($family == undef) {
    fail('family parameter must be set')
  }

  if ($update_version == undef) {
    fail('update version parameter must be set')
  }
  
  if ($hot_deploy == undef) {
    fail('hot deploy parameter must be set')
  }
  
  if (($hot_deploy != 'yes') and ($hot_deploy != 'no')) {
    fail('hot deploy parameter must have value "yes" or "no"')
  }

  if ($war_versioned == undef) {
    $defined_war_versioned = 'no'
  } else {
    $defined_war_versioned = $war_versioned
  }
  
  if ($as_service == undef) {
    $defined_as_service = "no"
  } else {
    $defined_as_service = $as_service
  }
  
  if ($direct_restart == undef) {
    $restart = "yes"
  } else {
    $restart = $direct_restart
  }

  if ($deploy_path == undef) {
    $defined_deploy_path = $default_deploy
  } else {
    $defined_deploy_path = $deploy_path
  }

  if ($installdir == undef) {
    $defined_installdir = '/opt/'
  } else {
    $defined_installdir = $installdir
  }

  if ($tmpdir == undef) {
    $defined_tmpdir = '/tmp/'
  } else {
    $defined_tmpdir = $tmpdir
  }

  if (($defined_deploy_path != $default_deploy) and ($context == undef)) {
    fail('context parameter must be set if deploy path is different from /webapps/')
  }
  
  if (($symbolic_link == undef)){
    $defined_symbolic_link = 'no'
  } else {
    $defined_symbolic_link = $symbolic_link
  }

  if ($external_conf == undef) {
    $defined_ext_conf = 'no'
  } else {
    $defined_ext_conf = $external_conf
  }

  if (($defined_ext_conf == 'yes')) {
    if ($external_conf_path == undef) {
      $defined_ext_conf_path = '/conf/'
    } else {
      $defined_ext_conf_path = $external_conf_path
    }

    if ($external_dir == undef) {
      fail('external dir parameter must be set if external_conf is equal to yes')
    }
  }
  
  
  exec { "tomcat::deploy::sleep_deploy::${war_name}": command => "sleep 10", }
  
  if ($hot_deploy == "no"){
    if ($as_service == "yes"){
      exec { "tomcat::deploy::stop_tomcat_as_service::${war_name}":
        command => "service tomcat stop",
        onlyif  => "ps -eaf | grep ${installdir}${tomcat}-${family}.0.${update_version}",
        require => Exec["tomcat::deploy::sleep_deploy::${war_name}"]
        }
    } else {
		  exec { "tomcat::deploy::stop_tomcat::$war_name":
		    command => "${installdir}${tomcat}-${family}.0.${update_version}/bin/shutdown.sh",
		    onlyif  => "ps -eaf | grep ${installdir}${tomcat}-${family}.0.${update_version}",
        require => Exec["tomcat::deploy::sleep_deploy::${war_name}"]}
		  }
    }

  if ($defined_ext_conf == 'yes') {
    exec { "tomcat::deploy::app_conf_path::${war_name}":
      command => "mkdir -p ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_ext_conf_path}",
      alias   => "tomcat::deploy::app_conf_path::${war_name}"
    }

    file { "${defined_tmpdir}${external_dir}":
      ensure  => directory,
      source  => "puppet:///modules/tomcat/${external_dir}",
      require => Exec["tomcat::deploy::app_conf_path::${war_name}"],
      alias   => "tomcat::deploy::tmp_conf::${war_name}",
      recurse => true
    }

    exec { "tomcat::deploy::move_conf::${war_name}":
      command => "mv ${defined_tmpdir}${external_dir} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_ext_conf_path}",
      require => [File["tomcat::deploy::tmp_conf::${war_name}"], Exec["tomcat::deploy::app_conf_path::${war_name}"]],
      alias   => "tomcat::deploy::move_conf::${war_name}"
    }

    exec { "tomcat::deploy::clean_conf::${war_name}":
      command   => "rm -rf ${defined_tmpdir}${external_dir}",
      require   => Exec["tomcat::deploy::move_conf::${war_name}"],
      logoutput => "false"
    }
  }

  if ($defined_deploy_path == $default_deploy) {
    if ($defined_war_versioned == 'no') {
      file { "${defined_tmpdir}${war_name}${extension}":
        ensure => present,
        source => "puppet:///modules/tomcat/${war_name}${extension}",
        alias  => "tomcat::deploy::tmp_war::${war_name}"
      }

      exec { "tomcat::deploy::move_war::${war_name}":
        command => "mv ${defined_tmpdir}${war_name}${extension} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
        require => File["tomcat::deploy::tmp_war::${war_name}"],
        unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}",
        alias   => "tomcat::deploy::move_war::${war_name}"
      }

      exec { "tomcat::deploy::clean_war::${war_name}":
        command   => "rm -rf ${defined_tmpdir}${war_name}${extension}",
        require   => Exec["tomcat::deploy::move_war::${war_name}"],
        logoutput => "false"
      }

    } elsif ($defined_war_versioned == 'yes') {
      file { "${defined_tmpdir}${war_name}-${war_version}${extension}":
        ensure => present,
        source => "puppet:///modules/tomcat/${war_name}-${war_version}${extension}",
        alias  => "tomcat::deploy::tmp_war::${war_name}-${war_version}"
      }

      exec { "tomcat::deploy::move_war::${war_name}":
        command => "mv ${defined_tmpdir}${war_name}-${war_version}${extension} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
        require => File["tomcat::deploy::tmp_war::${war_name}-${war_version}"],
        unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}-${war_version}",
        alias   => "tomcat::deploy::move_war::${war_name}"
      }

      exec { "tomcat::deploy::clean_war::${war_name}":
        command   => "rm -rf ${defined_tmpdir}${war_name}-${war_version}${extension}",
        require   => Exec["tomcat::deploy::move_war::${war_name}"],
        logoutput => "false"
      }
    }
  } else {
    exec { "tomcat::deploy::create_alternative_deploy_path::${war_name}":
      command => "mkdir ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
      unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
      alias   => "tomcat::deploy::create_alternative_deploy_path::${war_name}"
    }

    exec { "tomcat::deploy::create_app_context_path::${war_name}":
      command => "mkdir -p ${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::context_path}",
      alias   => "tomcat::deploy::create_app_context_path::${war_name}"
    }

    file { "tomcat::deploy::app_context_xml::${war_name}":
      path    => "${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::context_path}${context}.xml",
      owner   => 'root',
      group   => 'root',
      require => [Exec["tomcat::deploy::create_app_context_path::${war_name}"]],
      mode    => '0644',
      content => template("tomcat/appcontext-${family}.erb")
    }

    if ($defined_war_versioned == 'no') {
      file { "${defined_tmpdir}${war_name}${extension}":
        ensure  => present,
        source  => "puppet:///modules/tomcat/${war_name}${extension}",
        require => Exec["tomcat::deploy::create_alternative_deploy_path::${war_name}"],
        alias   => "tomcat::deploy::tmp_war::${war_name}"
      }

      exec { "tomcat::deploy::move_war::${war_name}":
        command => "mv ${defined_tmpdir}${war_name}${extension} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
        require => [File["tomcat::deploy::tmp_war::${war_name}"], Exec["tomcat::deploy::create_alternative_deploy_path::${war_name}"], File["tomcat::deploy::app_context_xml::${war_name}"]],
        unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}",
        alias   => "tomcat::deploy::move_war::${war_name}"
      } 

      exec { "tomcat::deploy::clean_war::${war_name}":
        command   => "rm -rf ${defined_tmpdir}${war_name}${extension}",
        require   => Exec["tomcat::deploy::move_war::${war_name}"],
        logoutput => "false"
      }

    } elsif ($defined_war_versioned == 'yes') {
      file { "${defined_tmpdir}${war_name}-${war_version}${extension}":
        ensure => present,
        source => "puppet:///modules/tomcat/${war_name}-${war_version}${extension}",
        alias  => "tomcat::deploy::tmp_war::${war_name}-${war_version}"
      }

      exec { "tomcat::deploy::move_war::${war_name}":
        command => "mv ${defined_tmpdir}${war_name}-${war_version}${extension} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}",
        require => [File["tomcat::deploy::tmp_war::${war_name}-${war_version}"], Exec["tomcat::deploy::create_alternative_deploy_path::${war_name}"], File["tomcat::deploy::app_context_xml::${war_name}"]],
        unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}-${war_version}",
        alias   => "tomcat::deploy::move_war::${war_name}"
      }
      
      if ($defined_symbolic_link == 'yes'){
	      exec { "tomcat::deploy::create_ln::${war_name}":
	        command => "ln -s ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}-${war_version}${extension} ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}${extension}",
	        require => [File["tomcat::deploy::tmp_war::${war_name}-${war_version}"],Exec["tomcat::deploy::create_alternative_deploy_path::${war_name}"], File["tomcat::deploy::app_context_xml::${war_name}"]],
	        unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}${extension}",
	        alias   => "tomcat::deploy::create_ln::${war_name}"
	      }
      }

      exec { "tomcat::deploy::clean_war::${war_name}":
        command   => "rm -rf ${defined_tmpdir}${war_name}-${war_version}${extension}",
        require   => Exec["tomcat::deploy::move_war::${war_name}"],
        logoutput => "false"
      }
    }
  }

  if ($hot_deploy == "no"){ 
	  if ($defined_as_service == 'no') {
	    if ($restart == 'yes') {
	      exec { "tomcat::deploy::restart::${war_name}":
	        command => "${installdir}${tomcat}-${family}.0.${update_version}/bin/startup.sh",
	        require => [Exec["tomcat::deploy::stop_tomcat::$war_name"],Exec["tomcat::deploy::move_war::${war_name}"]]
	       }
	     }
	  } elsif ($defined_as_service == "yes") {
	    if ($restart == 'yes') {
	      exec { "tomcat::deploy::restart_tomcat::${war_name}":
	        command => "service tomcat start",
	        require => [Exec["tomcat::deploy::stop_tomcat_as_service::$war_name"],Exec["tomcat::deploy::move_war::${war_name}"]],
	      }
	    }
	  }
 }
}