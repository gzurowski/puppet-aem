# == Define: aem::config
#
# Configure the AEM instance with the appropriate parameter values
#
# Do not use this defines directly.
#
define aem::config(
  $context_root,
  $debug_port,
  $group,
  $home,
  $jvm_mem_opts,
  $jvm_opts,
  $osgi_configs,
  $port,
  $runmodes,
  $sample_content,
  $type,
  $user
) {
  if $osgi_configs {

    if is_array($osgi_configs) {
      $_osgi_configs = $osgi_configs
    } else {
      $_osgi_configs = [$osgi_configs]
    }

    $_osgi_configs.each | Hash $cfg | {

      $cfg.each | $key, $values | {

        if $values['properties'] {
          $_props = $values['properties']
          $_pid = $values['pid']
        } else {
          $_props = $values
          $_pid = undef
        }

        aem::osgi::config { $key :
          group      => $group,
          home       => $home,
          pid        => $_pid,
          properties => $_props,
          type       => 'file',
          user       => $user
        }
      }
    }
  }
}
