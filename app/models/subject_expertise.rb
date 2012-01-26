class SubjectExpertise < ActiveRecord::Base
  has_many :user_subject_expertises
  has_many :users, :through => :user_subject_expertises
end
