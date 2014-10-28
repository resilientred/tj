require "pathname"
require "fileutils"
require "tempfile"
require "colorize"
require "thor"

###
# Module
###
require_relative "tinder"

###
# Subcommands
###
require_relative "tinder/scaffold"
require_relative "tinder/tasks/guard"
require_relative "tinder/tasks/composer"
require_relative "tinder/tasks/vagrant"
require_relative "tinder/tasks/capistrano"
require_relative "tinder/tasks/wpcli"

module Tinder

    ###
    # CLI interface to run subcommands from
    ###
    class CLI < ::Thor
        include ::Thor::Actions

        # ###
        # # Guard
        # ###
        # desc "watch", "Watch and compile assets with Guard"
        # subcommand "watch", ::Tinder::Tasks::Guard
        #
        # ###
        # # Composer
        # ###
        # desc "dependencies", "Manage vendor dependencies with Composer"
        # subcommand "dependencies", ::Tinder::Tasks::Composer
        #
        # ###
        # # Vagrant
        # ###
        # desc "vm", "Manage virtual development environment with Vagrant"
        # subcommand "vm", ::Tinder::Tasks::Vagrant
        #
        # ###
        # # Capistrano
        # ###
        # desc "deploy", "Run deployment and migration command with Capistrano"
        # subcommand "deploy", ::Tinder::Tasks::Capistrano

        ###
        # Non Thor commands
        ###
        no_commands do

            def setup
                ::Tinder::warning "Making sure all dependencies are installed..."

                ###
                # Vagrant
                ###
                if ::Tinder::installed? "vagrant"
                    ::Tinder::success "Vagrant is installed!"
                else
                    ::Tinder::error "Vagrant doesn't seem to be installed. Download Vagrant and VirtualBox before running this task. See README for more information."
                    exit -1
                end

                ###
                # Composer
                ###
                if ::Tinder::installed? "composer"
                    ::Tinder::success "Composer is installed!"
                else
                    ::Tinder::error "Composer doesn't seem to be installed, or is not globally executable."
                    answer = ask "Do you want to globally install it?", :limited_to => ["yes", "no"]

                    if answer == "yes"
                        ::Tinder::warning "Installing Composer..."
                        ::Tinder::warning "This task uses `sudo` to move the installed `composer.phar` into your `/usr/local/bin` so that it will be globally executable."
                        run [
                            "curl -sS https://getcomposer.org/installer | php",
                            "sudo mv composer.phar /usr/local/bin/composer"
                        ].join " && "
                    else
                        ::Tinder::warning "To use Tinder, install Composer manually and make sure it is globally executable."
                        exit -1
                    end
                end

                ###
                # WP-CLI
                ###
                if ::Tinder::installed? "wp"
                    ::Tinder::success "WP-CLI is installed!"
                else
                    ::Tinder::error "WP-CLI doesn't seem to be installed, or is not globally executable."
                    answer = ask "Do you want to globally install it?", :limited_to => ["yes", "no"]

                    if answer == "yes"
                        ::Tinder::warning "Installing WP-CLI..."
                        ::Tinder::warning "This task uses `sudo` to move the installed `wp-cli.phar` into your `/usr/local/bin` so that it will be globally executable."
                        run [
                            "curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar",
                            "chmod +x wp-cli.phar",
                            "sudo mv wp-cli.phar /usr/local/bin/wp"
                        ].join " && "
                    else
                        ::Tinder::warning "To use Tinder, install WP-CLI manually and make sure it is globally executable."
                        exit -1
                    end
                end
            end
        end

        ###
        # Install and setup VVV environment
        #
        # It will automagically set up your entire development environment, including
        #   a local development site at `http://site.dev` with WordPress installed
        #   and with a fresh WP database. It will also sync up your current theme
        #   folder with the theme folder on the Vagrant VM. This task will also
        #   install and configure Vagrant/VVV into your `~/` directory.
        ###
        desc "create THEME", "Setup new THEME and virtual development environment with Vagrant"
        method_option :bare, :default => nil
        def create(theme = nil)
            self.setup

            ::Tinder::warning "Just a few questions before we begin..."

            # Ask for the theme name
            theme ||= ask("[?] Theme name (required):").downcase

            # Make sure theme name was given, else throw err
            unless theme.empty?

                theme_location = ask "[?] Theme location (e.g. /path/to/site):",
                    :default => Dir.pwd
                dev_url = ask "[?] Development url (e.g. site.dev):",
                    :default => "#{theme}.dev"
                repository = ask "[?] Git repository:",
                    :default => "none"
                db_name = ask "[?] Database name:",
                    :default => theme.gsub(/[^\w]/, "_")
                db_user = ask "[?] Database username:",
                    :default => theme.gsub(/[^\w]/, "_")
                db_pass = ask "[?] Database password:",
                    :default => theme
                db_host = ask "[?] Database host:",
                    :default => dev_url # "192.168.50.4"

                # Ask for other options
                opts = {
                    :theme_name => theme,
                    :theme_location => File.expand_path(theme_location),
                    :bare_install => options[:bare],
                    :dev_location => File.expand_path("~/vagrant/www/dev-#{theme}"),
                    :dev_url => dev_url,
                    :repository => repository,
                    :db_name => db_name.gsub(/[^\w]/, "_"),
                    :db_user => db_user.gsub(/[^\w]/, "_"),
                    :db_pass => db_pass,
                    :db_host => db_host
                }

                # Create the theme!
                ::Tinder::Scaffold::create opts
            else
                ::Tinder::error "Theme name is required. Aborting mission."
                exit -1
            end
        end

        ###
        # Remove all traces of site from Vagrant
        #
        # @param {String} theme
        #   Theme to delete. This will not delete your local files, only the VVV env.
        ###
        desc "delete THEME", "Remove THEME from Vagrant development environment"
        method_option :restart, :default => nil
        def delete(theme)
            ::Tinder::warning "This method does not remove your local theme. It will only remove the site from within the VM."

            answer = ask "Are you sure you want to delete theme `#{theme}`?",
                :limited_to => ["yes", "no"]

            if answer == "yes"
                ::Tinder::Scaffold::delete theme, options[:restart]
            end
        end
    end
end
