app_path = "/home/regner/regner-share/current"

worker_processes 3
preload_app true
timeout 300
listen "0.0.0.0:9000"

working_directory app_path

rails_env = ENV['RAILS_ENV'] || 'production'

stderr_path "log/unicorn.error.log"
stdout_path "log/unicorn.log"

pid "#{app_path}/tmp/unicorn.pid"


__END__
# Environments
rails_env
unicorn_env        'production'
unicorn_rack_env   'deployment'

# Execution
unicorn_user       'regner'
unicorn_bundle     'bundle'
unicorn_bin        'unicorn'
unicorn_options
unicorn_restart_sleep_time  2

# Relative paths
app_subdir
unicorn_config_rel_path            'config'
unicorn_config_filename            'unicorn.rb'
unicorn_config_rel_file_path       'config/unicorn.rb'
unicorn_config_stage_rel_file_path 'config/unicorn/production.rb'

# Absolute paths
app_path                  '/home/regner/regner-share/current/'
unicorn_pid
#bundle_gemfile            /home/regner/regner-share/current/Gemfile
unicorn_config_path       '/home/regner/regner-share/current/config'
unicorn_config_file_path  '/home/regner/regner-share/current/config/unicorn.rb'
unicorn_config_stage_file_path "/home/regner/regner-share/current/config/unicorn/production.rb"
