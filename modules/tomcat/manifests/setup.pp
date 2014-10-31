# tomcat::setup defines the setup stage of Tomcat installation
define tomcat::setup (
  $family         = undef,
  $update_version = undef,
  $extension      = undef,
  $source_mode    = undef,
  $tmpdir         = undef,
  $installdir     = undef,
  $install_mode   = undef,
  $data_source    = undef,
  $driver_db      = undef,
  $ssl            = undef,
  $users          = undef,
  $access_log     = undef,
  $as_service     = undef,
  $direct_start   = undef) {
  include tomcat::params
  include tomcat::data_source
  include tomcat::config
  include tomcat::users

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

  if ($users == undef) {
    fail('users parameter must be set')
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

  if (($users != 'yes') and ($users != 'no')) {
    fail('users parameter must have value "yes" or "no"')
  }

  if (($ssl != 'yes') and ($ssl != 'no')) {
    fail('ssl parameter must have value "yes" or "no"')
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

  if ($direct_start == undef) {
    $start = "no"
  } else {
    $start = $direct_start
  }

  if ($access_log == undef) {
    $defined_access_log = "no"
  } else {
    $defined_access_log = $access_log
  }

  if ($as_service == undef) {
    $defined_as_service = "no"
  } else {
    $defined_as_service = $as_service
  }

  if ($data_source == "yes") {
    if ($driver_db == undef) {
      $defined_driver_db = "no"
    } else {
      $defined_driver_db = $driver_db
    }
  }

  if ($extension == ".zip") {
    $extractor_command = "unzip"
    $extractor_option_source = ""
    $extractor_option_dir = "-d"
  }

  if ($extension == ".tar.gz") {
    $extractor_command = "tar"
    $extractor_option_source = "-xzvf"
    $extractor_option_dir = "-C"
  }

  $tomcat = "apache-tomcat"
  $web_repo_path = hiera('tomcat::params::web_repository')

  if ($source_mode == "local") {
    file { "${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension}":
      ensure => present,
      source => "puppet:///modules/tomcat/${tomcat}-${family}.0.${update_version}${extension}"
    }

    exec { "tomcat::setup::extract_tomcat::${tomcat}-${family}.0.${update_version}":
      command => "${extractor_command} ${extractor_option_source} ${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension} ${extractor_option_dir} ${defined_tmpdir}",
      require => [File["${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension}"], Package['tar'], Package['unzip']],
      unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}/",
      alias   => "tomcat::setup::extract_tomcat::${tomcat}-${family}.0.${update_version}"
    }
  } elsif ($source_mode == "web") {
    $source = "${web_repo_path}tomcat-${family}/v${family}.0.${update_version}/bin/${tomcat}-${family}.0.${update_version}${extension}"

    exec { "tomcat::setup::retrieve_tomcat::${tomcat}-${family}.0.${update_version}":
      command => "wget -q ${source} -P ${defined_tmpdir}",
      unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}/",
      timeout => 1000
    }

    exec { "tomcat::setup::extract_tomcat::${tomcat}-${family}.0.${update_version}":
      command => "${extractor_command} ${extractor_option_source} ${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension} ${extractor_option_dir} ${defined_tmpdir}",
      require => [Exec[ "tomcat::setup::retrieve_tomcat::${tomcat}-${family}.0.${update_version}"]],
      alias   => "tomcat::setup::extract_tomcat::${tomcat}-${family}.0.${update_version}"
    }
  }

  file { "$defined_installdir":
    ensure => directory,
    mode   => '755',
    owner  => 'root',
    alias  => "tomcat::setup::tomcat_home::${tomcat}-${family}.0.${update_version}"
  }

  exec { "tomcat::setup::move_tomcat::${tomcat}-${family}.0.${update_version}":
    command => "mv ${defined_tmpdir}${tomcat}-${family}.0.${update_version}/ ${defined_installdir}",
    require => [File["tomcat::setup::tomcat_home::${tomcat}-${family}.0.${update_version}"], Exec["tomcat::setup::extract_tomcat::${tomcat}-${family}.0.${update_version}"]],
    unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}/"
  }

  if ($install_mode == "custom") {
    file { "tomcat::setup::serverxml::${tomcat}-${family}.0.${update_version}":
      path    => "${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::server_xml}",
      owner   => 'root',
      group   => 'root',
      require => Exec["tomcat::setup::move_tomcat::${tomcat}-${family}.0.${update_version}"],
      mode    => '0644',
      content => template("tomcat/serverxml-${family}.erb")
    }

    file { "tomcat::setup::contextxml::${tomcat}-${family}.0.${update_version}":
      path    => "${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::context_xml}",
      owner   => 'root',
      group   => 'root',
      require => Exec["tomcat::setup::move_tomcat::${tomcat}-${family}.0.${update_version}"],
      mode    => '0644',
      content => template("tomcat/context-${family}.erb")
    }

    file { "tomcat::setup::usersxml::${tomcat}-${family}.0.${update_version}":
      path    => "${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::users_xml}",
      owner   => 'root',
      group   => 'root',
      require => Exec["tomcat::setup::move_tomcat::${tomcat}-${family}.0.${update_version}"],
      mode    => '0644',
      content => template("tomcat/users-${family}.erb")
    }

    if ($data_source == "yes") {
      if ($defined_driver_db == "yes") {
        file { "${defined_tmpdir}${tomcat::data_source::ds_drivername}":
          ensure => present,
          source => "puppet:///modules/tomcat/${tomcat::data_source::ds_drivername}"
        }
      }

      exec { "tomcat::setup::move_driver::${tomcat}-${family}.0.${update_version}":
        command => "mv ${defined_tmpdir}${tomcat::data_source::ds_drivername} ${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::lib_path}",
        require => [File["${defined_tmpdir}${tomcat::data_source::ds_drivername}"], Exec["tomcat::setup::move_tomcat::${tomcat}-${family}.0.${update_version}"]],
        unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::lib_path}${tomcat::data_source::ds_drivername}"
      }
    }

    if ($ssl == "yes") {
      file { "${defined_tmpdir}${tomcat::params::https_keystore}":
        ensure => present,
        source => "puppet:///modules/tomcat/${tomcat::params::https_keystore}"
      }

      exec { "tomcat::setup::move_keystore::${tomcat}-${family}.0.${update_version}":
        command => "mv ${defined_tmpdir}${tomcat::params::https_keystore} ${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::conf_path}",
        require => [File["${defined_tmpdir}${tomcat::params::https_keystore}"], Exec["tomcat::setup::move_tomcat::${tomcat}-${family}.0.${update_version}"]],
        unless  => "ls ${defined_installdir}${tomcat}-${family}.0.${update_version}${tomcat::config::conf_path}${tomcat::params::https_keystore}"
      }
    }

  }

  exec { "tomcat::setup::clean_tomcat::${tomcat}-${family}.0.${update_version}":
    command   => "rm -rf ${defined_tmpdir}${tomcat}-${family}.0.${update_version}${extension}",
    require   => Exec["tomcat::setup::move_tomcat::${tomcat}-${family}.0.${update_version}"],
    logoutput => "false"
  }

  if ($defined_as_service == 'no') {
    if ($start == "yes") {
      exec { "tomcat::setup::make_executable::${tomcat}-${family}.0.${update_version}":
        command => "chmod +x ${installdir}${tomcat}-${family}.0.${update_version}/bin/*.sh",
        require => Exec["tomcat::setup::move_tomcat::${tomcat}-${family}.0.${update_version}"],
        alias   => "tomcat::setup::make_executable::${tomcat}-${family}.0.${update_version}"
      }

      exec { "tomcat::setup::start_tomcat::${tomcat}-${family}.0.${update_version}":
        command => "${installdir}${tomcat}-${family}.0.${update_version}/bin/startup.sh",
        require => [Exec["tomcat::setup::make_executable::${tomcat}-${family}.0.${update_version}"], Exec["tomcat::setup::move_tomcat::${tomcat}-${family}.0.${update_version}"]]
      }
    }
  } elsif ($defined_as_service == "yes") {
    file { "tomcat::setup::tomcat-service_sh::${tomcat}-${family}.0.${update_version}":
      path    => "/etc/init.d/tomcat",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("tomcat/tomcat-service.erb"),
      alias => "tomcat::setup::tomcat-service_sh::${tomcat}-${family}.0.${update_version}",
      require => Exec["tomcat::setup::move_tomcat::${tomcat}-${family}.0.${update_version}"]
    }

      exec { "tomcat::setup::make_tomcat_service_exec::${tomcat}-${family}.0.${update_version}":
        command => "chmod u+x /etc/init.d/tomcat",
        require => [File["tomcat::setup::tomcat-service_sh::${tomcat}-${family}.0.${update_version}"],Exec["tomcat::setup::move_tomcat::${tomcat}-${family}.0.${update_version}"]],
        alias => "make_tomcat_service_exec"
      }
   
    if ($start == "yes") {
      exec { "tomcat::setup::make_executable::${tomcat}-${family}.0.${update_version}":
        command => "chmod +x ${installdir}${tomcat}-${family}.0.${update_version}/bin/*.sh",
        require => Exec["tomcat::setup::move_tomcat::${tomcat}-${family}.0.${update_version}"],
        alias   => "tomcat::setup::make_executable::${tomcat}-${family}.0.${update_version}"
      }
      
      exec { "tomcat::setup::start_tomcat::${tomcat}-${family}.0.${update_version}":
        command => "service tomcat start",
        require => [File["tomcat::setup::tomcat-service_sh::${tomcat}-${family}.0.${update_version}"], Exec["tomcat::setup::make_executable::${tomcat}-${family}.0.${update_version}"], Exec["tomcat::setup::make_tomcat_service_exec::${tomcat}-${family}.0.${update_version}"], Exec["tomcat::setup::move_tomcat::${tomcat}-${family}.0.${update_version}"]]
      }
  }
  }
 }