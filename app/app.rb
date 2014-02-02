class RegnerShare < Padrino::Application
  register LessInitializer
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers
  register Padrino::Admin::AccessControl

  external_config = YAML.load_file(File.join(File.dirname(__FILE__), '../config/credentials.yml'))
  external_config.each_pair do |key, value|
    set key, value
  end

  # automatic thumbnailing
  # TODO make a helper function and config options so that we can have a secret
  use Rack::Thumb #, :prefix => "/dl/" # :secret => "e08thq3t0fhsdiohjrw", :keylength => 10}

  set :admin_model, 'User'
  set :login_page, '/sessions/new'

  get '/' do
    if current_account
      redirect url(:view, :tree)
    else
      redirect url(:sessions, :new)
    end
  end

  after do
    request.session_options[:skip] = true unless request.path_info.match /^\/(auth|invitations|sessions)\//
  end

  RegnerSettings = settings

  # Auth middleware
  use OmniAuth::Builder do
    provider :twitter, RegnerSettings.oauth_providers[:twitter][:id], RegnerSettings.oauth_providers[:twitter][:key]
    provider :facebook, RegnerSettings.oauth_providers[:facebook][:id], RegnerSettings.oauth_providers[:facebook][:key], { scope: 'email' }
    provider :google_oauth2, RegnerSettings.oauth_providers[:google_oauth2][:id], RegnerSettings.oauth_providers[:google_oauth2][:key], {access_type: 'online', approval_prompt: ''}
    provider :github, RegnerSettings.oauth_providers[:github][:id], RegnerSettings.oauth_providers[:github][:key], {scope: "user"}
    provider :dropbox, RegnerSettings.oauth_providers[:dropbox][:id], RegnerSettings.oauth_providers[:dropbox][:key]
  end

  OmniAuth.config.full_host = "http://share.aregner.com"

  # Access control
  access_control.roles_for :any do |role|
    role.protect "/"
    role.allow "/sessions"
    role.allow "/auth"
    role.allow "/invitation"
  end

  access_control.roles_for :friend, :admin do |role|
    role.project_module :view, '/view'
  end

  access_control.roles_for :admin do |role|
    role.project_module :share, '/share'
  end

  set :delivery_method, :smtp => {
    address: settings.mail_settings[:host],
    port: 587,
    user_name: settings.mail_settings[:user],
    password: settings.mail_settings[:password],
    authentication: :plain,
    enable_starttls_auto: true
  }

end
