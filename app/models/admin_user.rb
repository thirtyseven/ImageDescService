class AdminUser < ActiveRecord::Base
   
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise  :database_authenticatable, 
         :recoverable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :login
  
  
  validates_length_of :email, :within => 6..250 
  validates_uniqueness_of :email
  validates_presence_of  :email

  validates_length_of :login, :within => 5..40
  validates_uniqueness_of :login 
  validates_presence_of  :login
  
  validates_presence_of :password, :if => lambda {|user| user.new_record? }
  validates_length_of :password, :within => 6..40, :if => lambda {|user| !user.password.blank? }
  validates_confirmation_of :password
    
end
