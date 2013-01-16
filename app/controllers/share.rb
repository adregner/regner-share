RegnerShare.controllers :share do

  get :index do
    @tokens = AccessToken.all
    render 'share/tokens'
  end

  post :new do
    # create a new access token with some items for someone
    shared_items = params[:items].map{ |itemid| Item.find itemid }
    
    notices = []
    errors = []

    if params[:user]
      params[:user].map{ |user_id|
        logger.info "Looking up user id #{user_id}"
        User.find user_id
      }.each{ |user|
        logger.info "Adding token to #{user.inspect}"
        token = AccessToken.create! :hash => generate_token(), :desc => params[:desc], :items => shared_items
        user.access_tokens << token

        if user.save and deliver(:user, :new_shares_email, token, current_account)
          notices << user.name
        else
          errors << user.name
        end
      }
    end

    if params[:invitees]
      logger.info "processing invitations"
      email_addresses = params[:invitees].split(/ *, *| +/)
      email_addresses.each do |email_address|
        invitation = Invitation.create! hash: generate_token()[1..8].upcase, message: params[:desc], from_user_id: current_account.id
        invitation.user = User.create! email: email_address, role: "friend"
        token = AccessToken.create! :hash => generate_token(), :desc => params[:desc], :items => shared_items
        invitation.user.access_tokens << token
        logger.info "About to send an email to #{invitation.user.email} from #{current_account.email}"
        if invitation.save and deliver(:user, :invitation_email, invitation, current_account)
          notices << email_address
        else
          errors << email_address
        end
      end
    end

    flash[:notice] = notices.map{|email| "Access token for #{email} created successfully"}.join("\n")
    flash[:error] = errors.map{|email| "Error saving new user (#{email}) or sending their email.  They have not got their invitation."}.join("\n")

    redirect url(:share, :index)
  end

  get :edit, :with => :id do
    @token = AccessToken.find params[:id]
    render 'share/edit'
  end

  post :update, :with => :id do
    @token = AccessToken.find params[:id]
    if @token.update_attributes(params[:access_token])
      redirect url(:share, :index)
    else
      render 'share/edit'
    end
  end

  delete :invitation, :with => :id do
    begin
      invitation = Invitation.find params[:id] 
    rescue
      return redirect url(:sessions, :users)
    end

    if invitation.user.accounts.empty?
      invitation.user.access_tokens.map do |token|
        token.delete
      end
      invitation.user.delete
    end

    invitation.delete

    redirect url(:sessions, :users)
  end

  delete :destroy, :with => :id do
    token = AccessToken.find params[:id]
    token.delete
    
    redirect url(:share, :index)
  end

end
