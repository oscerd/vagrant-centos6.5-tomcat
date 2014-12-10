# tomcat::setup defines the setup stage of Tomcat installation
define tomcat::uninstall (
  $family = undef, 
  $update_version = undef, 
  $installdir = undef, 
  $as_service = undef
  ) {
  # Validate parameters presence
  if ($family == undef) {
    fail('family parameter must be set')
  }

  if ($update_version == undef) {
    fail('update version parameter must be set')
  }

  # Validate parameters

  if (($family != '6') and ($family != '7') and ($family != '8')) {
    fail('family parameter must be between "6" and "8" included')
  }

  if ($installdir == undef) {
    $defined_installdir = '/opt/'
  } else {
    $defined_installdir = $installdir
  }

  if ($as_service == undef) {
    $defined_as_service = "no"
  } else {
    $defined_as_service = $as_service
  }

  $tomcat = "apache-tomcat"

  exec { "tomcat::uninstall::sleep_deploy::${tomcat}-${family}.0.${update_version}": command => "sleep 10", }

  if ($as_service == "yes") {
    exec { "tomcat::uninstall::stop_tomcat_as_service::${tomcat}-${family}.0.${update_version}":
      command => "service tomcat stop",
      onlyif  => "ps -eaf | grep ${installdir}${tomcat}-${family}.0.${update_version}",
      require => Exec["tomcat::uninstall::sleep_deploy::${tomcat}-${family}.0.${update_version}"]
    }
  } else {
    exec { "tomcat::uninstall::stop_tomcat::${tomcat}-${family}.0.${update_version}":
      command => "${installdir}${tomcat}-${family}.0.${update_version}/bin/shutdown.sh",
      onlyif  => "ps -eaf | grep ${installdir}${tomcat}-${family}.0.${update_version}",
      require => Exec["tomcat::uninstall::sleep_deploy::${tomcat}-${family}.0.${update_version}"]
    }
  }

  if ($as_service == "yes") {
    exec { "tomcat::uninstall::remove_tomcat_as_service::${tomcat}-${family}.0.${update_version}":
      command => "rm -rf ${$defined_installdir}${tomcat}-${family}.0.${update_version}/",
      require => [
        Exec["tomcat::uninstall::sleep_deploy::${tomcat}-${family}.0.${update_version}"],
        Exec["tomcat::uninstall::stop_tomcat_as_service::${tomcat}-${family}.0.${update_version}"]]
    }

    exec { "tomcat::uninstall::remove_service_script::${tomcat}-${family}.0.${update_version}":
      command => "rm -rf /etc/init.d/tomcat",
      require => Exec["tomcat::uninstall::remove_tomcat_as_service::${tomcat}-${family}.0.${update_version}"]
    }
  } else {
    exec { "tomcat::uninstall::remove_tomcat::${tomcat}-${family}.0.${update_version}":
      command => "rm -rf ${$defined_installdir}${tomcat}-${family}.0.${update_version}/",
      require => [
        Exec["tomcat::uninstall::sleep_deploy::${tomcat}-${family}.0.${update_version}"],
        Exec["tomcat::uninstall::stop_tomcat::${tomcat}-${family}.0.${update_version}"]]
    }
  }
}
