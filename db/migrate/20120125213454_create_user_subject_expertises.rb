class CreateUserSubjectExpertises < ActiveRecord::Migration
  def self.up
    create_table :user_subject_expertises do |t|
      t.integer :user_id
      t.integer :subject_expertise_id
      t.timestamps
    end
  end

  def self.down
    drop_table :user_subject_expertises
  end
end
