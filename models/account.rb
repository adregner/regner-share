class Account
  include Mongoid::Document
  include Mongoid::Timestamps

  ####
  # This model is just a persistent representation of the user data
  # that the external services omniauth deals with will get us. An
  # actual user account is handled with the User model.
  ####

  field :provider, :type => String
  field :auth_id, :type => String
  field :name, :type => String
  field :email, :type => String

  belongs_to :user

  def self.create_with_omniauth(auth, current_account)
    create! do |account|
      account.provider = auth["provider"]
      account.auth_id = auth["uid"]
      account.name = auth["info"]["name"]
      account.email = auth["info"]["email"]

      # they should always have a current_account (User class) because
      # they are either an existing user adding a new auth
      # service (Account mdoel) or they were just invited.
      account.user = current_account or raise "No current user session."

      if current_account.name.nil? and account.name
        current_account.name = account.name
        current_account.save
      end
    end
  end

end
