RegnerShare.controllers :sessions do

  get :new do
    @unused_auth_services = [:facebook, :twitter, :google_oauth2, :github, :dropbox].delete_if{ |service|
      current_account ? current_account.accounts.map{|account| account.provider}.include?(service.to_s) : nil
    }.map{ |service|
      title = service.to_s.split('_')[0].capitalize
      {
        :name => service.to_s,
        :href => link_to(title, "/auth/#{service}"),
      }
    }
    render 'sessions/login'
  end

  get :auth, :map => '/auth/:provider/callback' do
    auth = request.env["omniauth.auth"]
    begin
      account = Account.find_by(provider: auth["provider"], auth_id: auth["uid"])
    rescue
      if current_account.nil?
        return [401, "You must be invited to gain access to this system."]
      else
        logger.info auth
        account = Account.create_with_omniauth(auth, current_account)
      end
    end
    set_current_account(account.user)
    redirect url(:sessions, :profile)
  end

  get :profile do
    if not current_account
      redirect url(:sessions, :new)
    end
    render 'sessions/profile'
  end

  get :logout do
    set_current_account(nil)
    redirect url(:sessions, :new)
  end

  ##### Administrative actions

  get :users do
    if current_account.role != "admin"
      flash[:error] = "You are not allowed to view this resource"
      redirect url(:sessions, :profile)
    end
    
    @users = User.all.delete_if{|user| user.accounts.empty? }
    @invitations = Invitation.all.map do |invitation|
      invitation[:from] = User.find invitation.from_user_id
      invitation[:items] = invitation.user.access_tokens.first.items
      invitation
    end
    render 'sessions/users'
  end

  delete :user, :with => :id do
    user = User.find params[:id]

    success = []
    success << user.access_tokens.map do |token|
      token.delete
    end
    success << user.accounts.map do |account|
      account.delete
    end
    success << user.delete

    if success.flatten.include? false
      flash[:error] = "Error removing something about this user, contact the administrator."
    else
      flash[:notice] = "User deleted successfully."
    end

    redirect url(:sessions, :users)
  end

end
