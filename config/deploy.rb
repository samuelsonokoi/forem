# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "sharply"
set :repo_url, "git@github.com:samuelsonokoi/forem.git"
set :branch, "samuelsonokoi/prod"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref samuelsonokoi/prod`.chomp

set :rbenv_type, :user
set :rbenv_ruby, "2.7.2"

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/deploy/#{fetch :application}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# Default value for :format is :pretty
set :format, :pretty

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle", ".bundle", "public/system",
       "public/uploads"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV["USER"]
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 10

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# puma
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_bind, "tcp://0.0.0.0:5000"
set :puma_threads, [0, 5]
set :puma_workers, 2
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true

set :sidekiq_env, "production"
set :sidekiq_pid, File.join(shared_path, "tmp", "pids", "sidekiq.pid")
set :sidekiq_log, File.join(shared_path, "log", "sidekiq.log")

namespace :puma do
  desc "Create Directories for Puma Pids and Socket"
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
  before :start, "deploy:migrate"
  before :restart, "deploy:migrate"
end

desc "Invoke a rake command on the remote server"
task :invoke, [:command] => "deploy:set_rails_env" do |_task, args|
  on primary(:app) do
    within current_path do
      with rails_env: fetch(:rails_env) do
        rake args[:command]
      end
    end
  end
end

namespace :deploy do
  task :initial do
    on roles(:app) do
      before "deploy:restart", "puma:start"
      invoke "deploy"
    end
  end

  after :restart, :clear_cache do
    invoke "puma:restart"
    on roles(:web), in: :groups, limit: 3, wait: 10
  end

  after :publishing, :restart
  after :finishing, :cleanup
  before :finishing, :restart
  after :rollback, :restart
end

namespace :rails do
  desc "Open the rails console on each of the remote servers"
  task console: "rvm:hook" do
    on roles(:app), primary: true do |host|
      execute_interactively host, "console production"
    end
  end
end

def execute_interactively(host, command)
  command = "cd #{fetch(:deploy_to)}/current && #{SSHKit.config.command_map[:bundle]} exec rails #{command}"
  Rails.logger.info command if fetch(:log_level) == :debug
  exec "ssh -l #{host.user} #{host.hostname} -p #{host.port || 22} -t " # {command}""
end
