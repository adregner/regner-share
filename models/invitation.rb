class Invitation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :hash, :type => String
  field :message, :type => String
  field :from_user_id, :type => Moped::BSON::ObjectId

  belongs_to :user

end
