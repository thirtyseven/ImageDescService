class CreateSubjectExpertises < ActiveRecord::Migration
  def self.up
    create_table :subject_expertises do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :subject_expertises
  end
end
