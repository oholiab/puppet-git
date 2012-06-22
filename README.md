# puppet-git
============

A puppet module for managing git resources

# To install into puppet

Clone into your puppet configuration in your `puppet/modules` directory:

 git clone git://github.com/nesi/puppet-git.git git

Or if you're managing your Puppet configuration with git, in your `puppet` directory:

		git submodule add git://github.com/nesi/puppet-git.git modules/git --init --recursive
		cd modules/git
		git checkout master
		git pull
		cd ../..
		git commit -m "added git submodule from https://github.com/nesi/puppet-git"

It might seem bit excessive, but it will make sure the submodule isn't headless...

# Usage

## To install git

A basic install with the defaults would be:

		 include git

Otherwise using the parametrs:

		class{git:
		  svn => true,
		  gui => true,
		}

### Parameters

* *svn* if true the git-svn package will also be installed
* *gui* if true the git-gui package will also be installed

## To set up git for a user

This basically sets the users name and email as git global variables, and should allow them to just use git. The username should be a valid user account.

With default settings just use:

		git::user{'username':}

Otherwise using parameters:

		git::user{'username':
		 user_name  => 'Some User',
		 user_email => 'someuser@example.org', 
		}

### Parameters

* *user_name* sets the user's name to the specified string, and not the default of '${name} on ${fqdn}', where fqdn is the fully qualified domain name as discovered by facter.
* *user_email* sets the user's email address to the specified string, and not the default of '${name}@${fqdn', where fqdn is the fully qualified domain name as discovered by facter.

## To specify a git repository

This will clone a git repository from a vaild git URI to a specified path on the target server. It is **strongly** recommended that *read-only* git URIs are used. If no source is given, the target path will simply be initialised as a git repository.

With minimum parameters, should create the directory `/usr/src/repo` and run `git init` in it:

		git::repo{'repo_name':
		  path => '/usr/src/repo',
		}

With minimum parameters to clone from a remote source:

		git::repo{'repo_name':
		 path   => '/usr/src/repo',
		 source => 'git://example.org/example/repo.git'
		}

### Parameters

* *path* sets the path where the git repository is created or cloned to
* *source* sets the git URI from which the git repository is cloned from
* *branch* this string sets a specific branch to check out
* *tag* this string sets a specific tag to check out
* *update* if set to true, when puppet runs it will revert any local changes and pull the current branch from the source if there is any difference between the local repository and the source repository.
*  *bare* if set to true, it creates a bare repository

**Note:** I am uncertain on how it will behave if both *tag* and *branch* are set, but *tag* should override *branch*.

# Further Development

I hope to add `gitolite` to this in due course.
