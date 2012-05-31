class AddContentModelToDescriptions < ActiveRecord::Migration
  def self.up
    add_column :dynamic_descriptions, :summary, :text, :limit => 16384
    add_column :dynamic_descriptions, :simplified_language_description, :text, :limit => 16384
    add_column :dynamic_descriptions, :target_age_start, :integer
    add_column :dynamic_descriptions, :target_age_end, :integer
    add_column :dynamic_descriptions, :target_grade_start, :integer
    add_column :dynamic_descriptions, :target_grade_end, :integer
    add_column :dynamic_descriptions, :description_quality, :integer
    add_column :dynamic_descriptions, :language, :string, :default => "en-US", :null => false
    add_column :dynamic_descriptions, :repository, :string, :default => "Bookshare", :null => false
    add_column :dynamic_descriptions, :credentials, :string
  end

  def self.down
  end
end
