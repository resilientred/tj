# Theme Juice
Command line interface to scaffold out a new WordPress development environment and countless sites. Everybody loves one command setups, and 'tj' even does one command deployments too.

## Installation
* First, install [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) for local development.
* Then, install [Composer](https://getcomposer.org/) and [WP-CLI](http://wp-cli.org/). _Make sure that these are executable from the command line._
* Finally, you can run: '$ gem install theme-juice-cli'

That's it!

## Usage

#### List available commands:
List all commands for 'tj'.
'''bash
tj
'''

#### Setup VVV:
This command will _only_ setup [Varying Vagrant Vagrants](https://github.com/Varying-Vagrant-Vagrants/VVV). It will not prompt you to create a new site. _Note: This is automatically run when you create your first site._
'''bash
tj init
'''

#### Create a new development site:
Use this to create a new development site. It will automagically set up your entire development environment, including a local development site at 'http://<sites-dev-url>.dev' with WordPress installed and a fresh WP database. It will sync up your local site installation with the Vagrant VM. This task will also install and configure Vagrant/VVV into your '~/' directory if it has not already been installed. Site name is optional, as it will be asked for if not given.
'''bash
tj create [<site-name>]
'''

#### Setup an existing site:
Use this to setup an existing local site installation within the development environment. You will go through the setup process to create the necessary files for the VM, including 'vvv-hosts', 'vvv-nginx.conf', and a fresh database (unless one already exists by the name chosen). Site name is optional, as it will be asked for if not given.
'''bash
tj setup [<site-name>] # Alias for 'tj create [<site-name>] --bare'
'''

#### Delete a site from the VM: _(Does not remove your local site)_
Use this to remove a site from your development environment. This is only remove files that were generated by 'tj'. including the database setup, development url, and shared directories. _It will not touch your local files._
'''bash
tj delete <site-name>
'''

#### List all sites in the VM:
Use this to list all sites within your development environment that were generated by 'tj'.
'''bash
tj list
'''

#### Watch and compile assets: _(Guard)_
Use this to watch and compile assets with [Guard](https://github.com/guard/guard). This is simply a wrapper for Guard commands.
'''bash
tj watch # Alias for 'bundle exec guard #{cmd}'
'''

#### Use for managing development environment: _(Vagrant)_
Use this to easily manage your [Varying Vagrant Vagrants](https://github.com/Varying-Vagrant-Vagrants/VVV) development environment. This is simply a wrapper for Vagrant commands.
'''bash
tj vm # Alias for 'cd ~/vagrant && vagrant #{cmd}'
'''

#### Use for managing vendor dependencies: _(Composer)_
Use this to easily manage your [Composer](https://github.com/composer/composer) dependencies. This is simply a wrapper for Composer commands.
'''bash
tj vendor # Alias for 'composer #{cmd}'
'''

#### Use for managing deployment and migration: _(Capistrano)_
Use this to easily manage your deployment and migration with [Capistrano](https://github.com/capistrano/capistrano). This is simply a wrapper for Capistrano commands.
'''bash
tj server # Alias for 'bundle exec cap #{cmd}'
'''

## Contributing

1. First, create an [issue](https://github.com/ezekg/theme-juice-cli/issues) for your proposed feature. If it's a bug fix, go right to step 2.
2. [Fork the repository](https://github.com/ezekg/theme-juice-cli/fork).
3. Create a new feature branch. ('git checkout -b my-new-feature')
4. Commit your changes. ('git commit -am 'Add some feature'')
5. Push to the new branch. ('git push origin my-new-feature')
6. Create a new Pull Request.
