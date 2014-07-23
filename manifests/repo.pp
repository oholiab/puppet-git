# = Define a git repository as a resource
#
# == Parameters:
#
# $source::     The URI to the source of the repository
#
# $path::       The path where the repository should be cloned to, fully qualified paths are recommended, and the $owner needs write permissions.
#
# $branch::     The branch to be checked out
#
# $git_tag::    The tag to be checked out
#
# $owner::      The user who should own the repository
#
# $update::     If this is true, puppet will revert local changes and pull remote changes when it runs.
#
# $bare::       If this is true, git will create a bare repository

define git::repo(
  $path,
  $source   = false,
  $branch   = undef,
  $git_tag  = undef,
  $owner    = 'root',
  $group    = 'root',
  $update   = false,
  $bare     = false,
  $submodule = false,
  $submodule_update = false,
){

  require git

  validate_bool($bare, $update)

  if $branch {
    $real_branch = $branch
  } else {
    $real_branch = 'master'
  }

  if $source {
    $init_cmd = "${git::bin} clone -b ${real_branch} ${source} ${path} --recursive"
  } else {
    if $bare {
      $init_cmd = "${git::bin} init --bare ${path}"
    } else {
      $init_cmd = "${git::bin} init ${path}"
    }
  }

  $submodule_init_cmd = "${git::bin} submodule init"
  $submodule_update_cmd = "${git::bin} submodule update"

  $creates = $bare ? {
    true    => "${path}/objects",
    default => "${path}/.git",
  }


  file{$path:
    ensure  => directory,
    owner => $owner,
    recurse => true,
  } ~>
  exec {"git_repo_${name}":
    command     => $init_cmd,
    user        => $owner,
    creates     => $creates,
    require     => Package[$git::git_package],
    timeout     => 600,
    refreshonly => true,
  }
  if $submodule {
    Exec["git_repo_${name}"] ~>
    exec {"submodule_${name}_init":
      user    => $owner,
      cwd     => $path,
      command => $submodule_init_cmd,
      refreshonly => true,
    } ~>
    exec {"submodule_${name}_first_update":
      user        => $owner,
      cwd         => $path,
      command     => $submodule_update_cmd,
      refreshonly => true,
    }
  }


  if $update {
    exec {"git_${name}_pull":
      user    => $owner,
      cwd     => $path,
      command => "${git::bin} reset --hard HEAD && ${git::bin} pull origin ${branch}",
      require => Exec["git_repo_${name}"],
    }
  }

  if $submodule_update {
    exec {"submodule_${name}_update":
      user    => $owner,
      cwd     => $path,
      command => $submodule_update_cmd,
      require => Exec["submodule_${name}_init"],
    }
  }



  # I think tagging works, but it's possible setting a tag and a branch will just fight.
  # It should change branches too...
  if $git_tag {
    exec {"git_${name}_co_tag":
      user    => $owner,
      cwd     => $path,
      command => "${git::bin} checkout ${git_tag}",
      unless  => "${git::bin} describe --tag|/bin/grep -P '${git_tag}'",
      require => Exec["git_repo_${name}"],
    }
  } elsif ! $bare {
    exec {"git_${name}_co_branch":
      user    => $owner,
      cwd     => $path,
      command => "${git::bin} checkout ${branch}",
      unless  => "${git::bin} branch|/bin/grep -P '\\* ${branch}'",
      require => Exec["git_repo_${name}"],
    }
  }

}
