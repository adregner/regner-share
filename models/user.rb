class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, :type => String
  field :name, :type => String
  field :role, :type => String
  
  has_many :accounts
  has_many :access_tokens

  has_one :invitation

  ##
  # Used by AuthenticationHelper
  def self.find_by_id(id)
    find(id) rescue nil
  end
end
