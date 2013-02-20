class RegnerShare < Padrino::Application
  register LessInitializer
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers
  register Padrino::Admin::AccessControl

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

  # Auth middleware
  use OmniAuth::Builder do
    provider :twitter, Creds[:twitter][:id], Creds[:twitter][:key]
    provider :facebook, Creds[:facebook][:id], Creds[:facebook][:key], { scope: 'email' }
    provider :google_oauth2, Creds[:google_oauth2][:id], Creds[:google_oauth2][:key], {access_type: 'online', approval_prompt: ''}
    provider :github, Creds[:github][:id], Creds[:github][:key], {scope: "user"}
    provider :dropbox, Creds[:dropbox][:id], Creds[:dropbox][:key]
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
    address: Creds[:mail][:host],
    port: 587,
    user_name: Creds[:mail][:user],
    password: Creds[:mail][:password],
    authentication: :plain,
    enable_starttls_auto: true
  }

end
