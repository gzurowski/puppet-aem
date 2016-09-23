# == Define: aem::package
#
# Used to unpack the AEM instance prior to configuration.
#
# Do not use this defines directly.
#
define aem::package (
  $ensure,
  $group,
  $home,
  $manage_home,
  $source,
  $user,
) {
  File {
    group => $group,
    owner => $user,
  }

  Exec {
    group => $group,
    path  => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    user  => $user,
  }

  if $ensure == 'present' {
    # Manage home directory.
    if !defined(File[$home]) and $manage_home {
      file { $home:
        ensure => directory,
        mode   => '0775',
      }
    }

    if defined(File[$home]) {
      File[$home]
      -> Exec["${name} unpack"]
    }

    # Unpack the Jar
    exec { "${name} unpack":
      command => "java -jar ${source} -b ${home} -unpack",
      creates => "${home}/crx-quickstart",
      onlyif  => ['which java', "test -f ${source}"],
    }
    
    # Create the install folder in case there are any OSGi configurations or content packages
    file {"${home}/crx-quickstart/install" :
      ensure => directory,
      mode   => '0775',
    }

    # Create the env script
    file { "${home}/crx-quickstart/bin/start-env":
      ensure  => file,
      content => template("${module_name}/start-env.erb"),
      mode    => '0775',
    }
  
    # Rename the original start script.
    file { "${home}/crx-quickstart/bin/start.orig":
      ensure  => file,
      replace => false,
      source  => "${home}/crx-quickstart/bin/start",
      mode    => '0775',
    }
  
    # Create the start script
    file { "${home}/crx-quickstart/bin/start":
      ensure  => file,
      content => template("${module_name}/start.erb"),
      mode    => '0775',
      require => File["${home}/crx-quickstart/bin/start.orig"],
    }

  } else {
    # Remove installation
    file { "${home}/crx-quickstart": ensure => absent, force => true }

    # Remove managed home directory
    if !defined(File[$home]) and $manage_home {
      file { $home:
        ensure => absent,
        force  => true,
      }
    }

    if defined(File[$home]) {
      File["${home}/crx-quickstart"]
      -> File[$home]
    }
  }
}
