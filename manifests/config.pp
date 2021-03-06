# == Class hue::config
#
# Configuration of Apache Hue.
#
class hue::config {
  file { "${hue::confdir}/hue.ini":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('hue/hue.ini.erb'),
  }

  $defaultdir = $hue::defaultdir
  $environment = $hue::_environment
  augeas{"${defaultdir}/hue":
    lens    => 'Shellvars.lns',
    incl    => "${defaultdir}/hue",
    changes => template('hue/hue-env.augeas.erb'),
  }

  if $hue::realm and !empty($hue::realm) {
    if $hue::keytab_source and !empty($hue::keytab_source) {
      file { $hue::keytab_hue:
        owner  => 'hue',
        group  => 'hue',
        mode   => '0600',
        source => $hue::keytab_source,
      }
    } else {
      file { $hue::keytab_hue:
        owner => 'hue',
        group => 'hue',
        mode  => '0600',
      }
    }
  }

  if $hue::_https_hue {
    file { $hue::_https_certificate:
      owner  => 'hue',
      group  => 'hue',
      mode   => '0644',
      source => $hue::https_certificate,
    }

    file { $hue::_https_private_key:
      owner  => 'hue',
      group  => 'hue',
      mode   => '0400',
      source => $hue::https_private_key,
    }
  }

  if $hue::auth == 'spnego' {
    file { $hue::_keytab_spnego:
      owner  => 'hue',
      group  => 'hue',
      mode   => '0400',
      source => $hue::keytab_spnego,
    }
  }
}
