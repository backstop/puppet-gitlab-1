# == Class gitlab::install
#
# This class is called from gitlab for install.
#
class gitlab::install {

  $edition             = $::gitlab::edition
  $manage_package_repo = $::gitlab::manage_package_repo
  $manage_package      = $::gitlab::manage_package
  $package_ensure      = $::gitlab::package_ensure
  $package_name        = "gitlab-${edition}"
  $package_pin         = $::gitlab::package_pin

  # only do repo management when on a Debian-like system
  if $manage_package_repo {
    case $::osfamily {
      'redhat': {
        if is_hash($::os) {
          $releasever = $::os[release][major]
        } else {
          $releasever = $::operatingsystemmajrelease
        }

        yumrepo { 'gitlab_official':
          descr         => 'Official repository for Gitlab',
          baseurl       => "https://packages.gitlab.com/gitlab/gitlab-${edition}/el/${releasever}/\$basearch",
          enabled       => 1,
          gpgcheck      => 0,
          gpgkey        => 'https://packages.gitlab.com/gpg.key',
          repo_gpgcheck => 1,
          sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
          sslverify     => 1,
        }

        if $manage_package {
          package { $package_name:
            ensure  => $package_ensure,
            require => Yumrepo['gitlab_official'],
          }
        }
      }
      default: {
        fail("OS family ${::osfamily} not supported")
      }
    }
  } elsif $manage_package  {
    package { $package_name:
      ensure => $package_ensure,
    }
  }

}
