# tomcat::setup defines the undeploy stage of a package
define tomcat::undeploy (
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
  $as_service         = undef,
  $direct_restart     = undef) {
  $extension = '.war'
  $tomcat = 'apache-tomcat'
  $default_deploy = '/webapps/'

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

  if ($war_versioned == undef) {
    $defined_war_versioned = 'no'
  } else {
    $defined_war_versioned = $war_versioned
  }

  if ($as_service == undef) {
    $defined_as_service = 'no'
  } else {
    $defined_as_service = $as_service
  }

  if ($direct_restart == undef) {
    $restart = 'no'
  } else {
    $restart = $direct_restart
  }

  if ($defined_war_versioned == 'yes') {
    if ($war_version == undef) {
      fail('war version parameter must be set, if war versioned parameter is set to yes')
    }
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

  if (($defined_deploy_path != $default_deploy) and ($context == undef)) {
    fail('context parameter must be set if deploy path is different from /webapps/')
  }

  if (($symbolic_link == undef)) {
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

  exec { "tomcat::undeploy::sleep_undeploy::${war_name}": command => 'sleep 10', }

  if ($defined_as_service == 'no') {
    exec { "tomcat::undeploy::shutdown::${war_name}":
      command => "${installdir}${tomcat}-${family}.0.${update_version}/bin/shutdown.sh",
      onlyif  => "ps -eaf | grep ${installdir}${tomcat}-${family}.0.${update_version}",
      require => Exec["tomcat::undeploy::sleep_undeploy::${war_name}"]
    }
  } else {
    exec { "tomcat::undeploy::shutdown::${war_name}":
      command => 'service tomcat stop',
      onlyif  => "ps -eaf | grep ${installdir}${tomcat}-${family}.0.${update_version}",
      require => Exec["tomcat::undeploy::sleep_undeploy::${war_name}"]
    }
  }

  if ($defined_deploy_path == $default_deploy) {
    if ($defined_war_versioned == 'no') {
      exec { "tomcat::undeploy::delete_package::${war_name}":
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}${extension}",
        require => [Exec["tomcat::undeploy::sleep_undeploy::${war_name}"], Exec["tomcat::undeploy::shutdown::${war_name}"]],
        alias   => "tomcat::undeploy::delete_package::${war_name}"
      }

      exec { "tomcat::undeploy::delete_folder::${war_name}":
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}",
        require => [
          Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
          Exec["tomcat::undeploy::shutdown::${war_name}"],
          Exec["tomcat::undeploy::delete_package::${war_name}"]],
        alias   => "tomcat::undeploy::delete_folder::${war_name}"
      }

      exec { "tomcat::undeploy::delete_work::${war_name}":
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::work_path_normal}${war_name}",
        require => [
          Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
          Exec["tomcat::undeploy::shutdown::${war_name}"],
          Exec["tomcat::undeploy::delete_package::${war_name}"],
          Exec["tomcat::undeploy::delete_folder::${war_name}"]],
        alias   => "tomcat::undeploy::delete_work::${war_name}"
      }

      if ($defined_ext_conf == 'yes') {
        exec { "tomcat::undeploy::delete_conf::${war_name}":
          command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_ext_conf_path}${external_dir}",
          require => [
            Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
            Exec["tomcat::undeploy::shutdown::${war_name}"],
            Exec["tomcat::undeploy::delete_package::${war_name}"],
            Exec["tomcat::undeploy::delete_folder::${war_name}"]],
          alias   => "tomcat::undeploy::delete_conf::${war_name}"
        }
      }
    } elsif ($defined_war_versioned == 'yes') {
      exec { "tomcat::undeploy::delete_package::${war_name}":
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}-${war_version}${extension}",
        require => [Exec["tomcat::undeploy::sleep_undeploy::${war_name}"], Exec["tomcat::undeploy::shutdown::${war_name}"]],
        alias   => "tomcat::undeploy::delete_package::${war_name}"
      }

      exec { "tomcat::undeploy::delete_folder::${war_name}":
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}-${war_version}",
        require => [
          Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
          Exec["tomcat::undeploy::shutdown::${war_name}"],
          Exec["tomcat::undeploy::delete_package::${war_name}"]],
        alias   => "tomcat::undeploy::delete_folder::${war_name}"
      }

      exec { "tomcat::undeploy::delete_work::${war_name}":
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::work_path_normal}${war_name}-${war_version}",
        require => [
          Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
          Exec["tomcat::undeploy::shutdown::${war_name}"],
          Exec["tomcat::undeploy::delete_package::${war_name}"],
          Exec["tomcat::undeploy::delete_folder::${war_name}"]],
        alias   => "tomcat::undeploy::delete_work::${war_name}"
      }

      if ($defined_ext_conf == 'yes') {
        exec { "tomcat::undeploy::delete_conf::${war_name}":
          command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_ext_conf_path}${external_dir}",
          require => [
            Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
            Exec["tomcat::undeploy::shutdown::${war_name}"],
            Exec["tomcat::undeploy::delete_package::${war_name}"],
            Exec["tomcat::undeploy::delete_folder::${war_name}"]],
          alias   => "tomcat::undeploy::delete_conf::${war_name}"
        }
      }
    }
  } else {
    if ($defined_war_versioned == 'no') {
      exec { "tomcat::undeploy::delete_package::${war_name}":
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}${extension}",
        require => [Exec["tomcat::undeploy::sleep_undeploy::${war_name}"], Exec["tomcat::undeploy::shutdown::${war_name}"]],
        alias   => "tomcat::undeploy::delete_package::${war_name}"
      }

      exec { "tomcat::undeploy::delete_folder::${war_name}":
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${default_deploy}${context}",
        require => [
          Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
          Exec["tomcat::undeploy::shutdown::${war_name}"],
          Exec["tomcat::undeploy::delete_package::${war_name}"]],
        alias   => 'delete_folder'
      }

      exec { "tomcat::undeploy::delete_context_file::${war_name}":
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::context_path}${context}.xml",
        require => [
          Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
          Exec["tomcat::undeploy::shutdown::${war_name}"],
          Exec["tomcat::undeploy::delete_package::${war_name}"],
          Exec["tomcat::undeploy::delete_folder::${war_name}"]],
        alias   => "tomcat::undeploy::delete_context_file::${war_name}"
      }

      exec { "tomcat::undeploy::delete_work::${war_name}":
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::work_path_context}${context}",
        require => [
          Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
          Exec["tomcat::undeploy::shutdown::${war_name}"],
          Exec["tomcat::undeploy::delete_package::${war_name}"],
          Exec["tomcat::undeploy::delete_folder::${war_name}"],
          Exec["tomcat::undeploy::delete_context_file::${war_name}"]],
        alias   => "tomcat::undeploy::delete_work::${war_name}"
      }

      if ($defined_ext_conf == 'yes') {
        exec { "tomcat::undeploy::delete_conf::${war_name}":
          command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_ext_conf_path}${external_dir}",
          require => [
            Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
            Exec["tomcat::undeploy::shutdown::${war_name}"],
            Exec["tomcat::undeploy::delete_package::${war_name}"],
            Exec["tomcat::undeploy::delete_folder::${war_name}"],
            Exec["tomcat::undeploy::delete_context_file::${war_name}"]],
          alias   => "tomcat::undeploy::delete_conf::${war_name}"
        }
      }

    } elsif ($defined_war_versioned == 'yes') {
      exec { "tomcat::undeploy::delete_package::${war_name}":
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}-${war_version}${extension}",
        require => [Exec["tomcat::undeploy::sleep_undeploy::${war_name}"], Exec["tomcat::undeploy::shutdown::${war_name}"]],
        alias   => "tomcat::undeploy::delete_package::${war_name}"
      }

      exec { "tomcat::undeploy::delete_folder::${war_name}":
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${default_deploy}${context}",
        require => [
          Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
          Exec["tomcat::undeploy::shutdown::${war_name}"],
          Exec["tomcat::undeploy::delete_package::${war_name}"]],
        alias   => "tomcat::undeploy::delete_folder::${war_name}"
      }

      exec { "tomcat::undeploy::delete_context_file::${war_name}":
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::context_path}${context}.xml",
        require => [
          Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
          Exec["tomcat::undeploy::shutdown::${war_name}"],
          Exec["tomcat::undeploy::delete_package::${war_name}"],
          Exec["tomcat::undeploy::delete_folder::${war_name}"]],
        alias   => "tomcat::undeploy::delete_context_file::${war_name}"
      }

      exec { "tomcat::undeploy::delete_work::${war_name}":
        command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::context_path}${context}",
        require => [
          Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
          Exec["tomcat::undeploy::shutdown::${war_name}"],
          Exec["tomcat::undeploy::delete_package::${war_name}"],
          Exec["tomcat::undeploy::delete_folder::${war_name}"],
          Exec["tomcat::undeploy::delete_context_file::${war_name}"]],
        alias   => "tomcat::undeploy::delete_work::${war_name}"
      }

      if ($defined_ext_conf == 'yes') {
        exec { "tomcat::undeploy::delete_conf::${war_name}":
          command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_ext_conf_path}${external_dir}",
          require => [
            Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
            Exec["tomcat::undeploy::shutdown::${war_name}"],
            Exec["tomcat::undeploy::delete_package::${war_name}"],
            Exec["tomcat::undeploy::delete_folder::${war_name}"],
            Exec["tomcat::undeploy::delete_context_file::${war_name}"]],
          alias   => "tomcat::undeploy::delete_conf::${war_name}"
        }
      }

      if ($symbolic_link == 'yes') {
        exec { "tomcat::undeploy::delete_symbolic_link::${war_name}":
          command => "rm -rf ${defined_installdir}${tomcat}-${family}.0.${update_version}${defined_deploy_path}${war_name}${extension}",
          require => [
            Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
            Exec["tomcat::undeploy::shutdown::${war_name}"],
            Exec["tomcat::undeploy::delete_package::${war_name}"],
            Exec["tomcat::undeploy::delete_folder::${war_name}"],
            Exec["tomcat::undeploy::delete_context_file::${war_name}"]],
          alias   => "tomcat::undeploy::delete_symbolic_link::${war_name}"
        }
      }
    }
  }

  if ($defined_as_service == 'no') {
    if ($restart == 'yes') {
      exec { "tomcat::undeploy::restart::${war_name}":
        command => "${installdir}${tomcat}-${family}.0.${update_version}/bin/startup.sh",
        require => [
          Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
          Exec["tomcat::undeploy::shutdown::${war_name}"],
          Exec["tomcat::undeploy::delete_package::${war_name}"],
          Exec["tomcat::undeploy::delete_folder::${war_name}"],
          Exec["tomcat::undeploy::delete_work::${war_name}"]]
      }
    }
  } elsif ($defined_as_service == 'yes') {
    if ($restart == 'yes') {
      exec { "tomcat::undeploy::restart_tomcat::${war_name}":
        command => 'service tomcat start',
        require => [
          Exec["tomcat::undeploy::sleep_undeploy::${war_name}"],
          Exec["tomcat::undeploy::shutdown::${war_name}"],
          Exec["tomcat::undeploy::delete_package::${war_name}"],
          Exec["tomcat::undeploy::delete_folder::${war_name}"],
          Exec["tomcat::undeploy::delete_work::${war_name}"]],
      }
    }
  }
}