# = Class: git::params
#
# Configure how the puppet git module behaves

class git::params {
  $svn_package  = 'git-svn'
  $gui_package  = 'git-gui'
  $bin          = '/usr/bin/git'
  if $::operatingsystem =~ /^(Debian|Ubuntu)$/ and versioncmp($::operatingsystemrelease, '12') < 0 {
    $git_package = 'git-core'
  }else{
     $git_package = 'git'
  }
}
