# config valid only for current version of Capistrano
lock "3.8.2"

set :application, "blog"
set :repo_url, "https://github.com/encoreshao/blog"
set :rvm_type, :user
set :rvm_ruby_version, "2.4.1@#{fetch(:application)}"

# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
# set :local_user, -> { `git config user.name`.chomp }

set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

append :linked_files, "config/database.yml", "config/secrets.yml"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

server 'icmoc.com', port: 22, roles: [:web, :app, :db], primary: true

## Defaults:
# set :scm,           :git
set :user,          'deploy'
set :branch,        :master
set :format,        :pretty
set :log_level,     :debug
set :keep_releases, 5

# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
# set :deploy_via,      :remote_cache
set :deploy_via,      :copy
set :deploy_to,       "/var/www/production/#{fetch(:application)}"

set :puma_threads,    [1, 4]
set :puma_workers,    1
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, false  # Change to true if using ActiveRecord

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
