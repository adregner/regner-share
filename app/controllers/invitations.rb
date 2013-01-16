RegnerShare.controllers :invitations do

  get :redeem, :with => :hash do
    invitation = Invitation.find_by hash: params[:hash]
    set_current_account(invitation.user)
    redirect url(:sessions, :new)
  end

end
