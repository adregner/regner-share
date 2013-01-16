# Helper methods defined here can be accessed in any controller or view in the application

RegnerShare.helpers do
  
  def generate_token
    @@rand ||= Random.new
    @@rand.rand(36**48).to_s(36)
  end
  
end
