RegnerShare.mailer :user do

  email :new_shares_email do |token, current_account|
    from current_account.email
    to token.user.email
    subject "You have new pictures from the Regner's"
    render 'user/new_shares_email', :locals => {:current_account => current_account, :token => token}
  end

  email :invitation_email do |invitation, current_account|
    from current_account.email
    to invitation.user.email
    subject "You have been invited to see some pictures from the Regner's"
    render 'user/invitation_email', :locals => {:current_account => current_account, :invitation => invitation}
  end

end
