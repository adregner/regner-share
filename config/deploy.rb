set :application, 'regner-share'
set :repo_url, 'git://github.com/adregner/regner-share'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/home/regner/regner-share'
# set :scm, :git

set :format, :pretty
# set :log_level, :debug
# set :pty, true

set :linked_files, %w{config/credentials.yml}
set :linked_dirs, %w{log tmp}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:web, :app), in: :sequence do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'

end
