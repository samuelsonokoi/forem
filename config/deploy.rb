# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "sharply"
set :repo_url, "git@github.com:samuelsonokoi/forem.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref samuelsonokoi/prod`.chomp
set :branch, "samuelsonokoi/prod"

set :rbenv_type, :user
set :rbenv_ruby, "2.7.2"

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/deploy/#{fetch :application}"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle", ".bundle", "public/system",
       "public/uploads"

# capistrano-rails config
set :assets_roles, %w[webpack] # Give the webpack role to a single server
set :assets_prefix, "packs" # Assets are located in /packs/
set :keep_assets, 10 # Automatically remove stale assets
set :assets_manifests, lambda { # Tell Capistrano-Rails how to find the Webpacker manifests
  [release_path.join("public", fetch(:assets_prefix), "manifest.json*")]
}

set :conditionally_migrate, false

# set :sidekiq_roles, :app
# set :sidekiq_default_hooks, true
# set :sidekiq_pid, File.join(shared_path, "tmp", "pids", "sidekiq.pid")
# set :sidekiq_env, fetch(:rack_env, fetch(:rails_env, fetch(:stage)))
# set :sidekiq_log, File.join(shared_path, "log", "sidekiq.log")
# set :sidekiq_user, nil

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV["USER"]
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 10

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
