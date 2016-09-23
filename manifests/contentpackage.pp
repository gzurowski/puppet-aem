# == Define: aem::contentpackage
#
# Used to manage installation of AEM content packages files.
#
#
define aem::contentpackage (
  $ensure      = 'present',
  $content_packages,
  $group       = 'aem',
  $home        = undef,
  $user        = 'aem') {

  validate_re($ensure, '^(present|absent)$', "${ensure} is not supported for ensure. Allowed values are 'present' and 'absent'.")

  if $home == undef {
    fail('Home directory must be specified.')
  }

  validate_absolute_path($home)

  if $content_packages {

    if is_array($content_packages) {
      $_content_packages = $content_packages
    } else {
      $_content_packages = [$content_packages]
    }

    $_content_packages.each | String $pkg | {
          file { "${home}/crx-quickstart/install/${pkg}" :
            ensure  => $ensure,
            source  => "/vagrant/puppet/files/${pkg}",
            group   => $group,
            mode    => '0664',
            owner   => $user,
          }
    }

  }
  
}

