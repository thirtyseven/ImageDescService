class UserSubjectExpertise < ActiveRecord::Base
  belongs_to :user
  belongs_to :subject_expertise
end
