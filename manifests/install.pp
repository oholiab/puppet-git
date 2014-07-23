# Git installer manifest
# DO NOT USE DIRECTLY
#
# Use this instead:
# include git
#
# or:
# class {'git':
#   svn => true,
#   gui => true,
#}

class git::install(
  $gui=$git::gui,
  $svn=$git::svn,
){

  package{$git::git_package: ensure => installed}

  if $svn {
    package{$git::svn_package: ensure => installed}
  } else {
    package{$git::svn_package: ensure => absent}
  }

  if $gui {
    package{$git::gui_package: ensure => installed}
  } else {
    package{$git::gui_package: ensure => absent}
  }

}
