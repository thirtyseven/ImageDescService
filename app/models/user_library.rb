class UserLibrary < ActiveRecord::Base
  belongs_to :user
  belongs_to :library
end
