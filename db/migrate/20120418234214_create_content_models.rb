class CreateContentModels < ActiveRecord::Migration
  def self.up
    create_table :content_models do |t|
      t.text :summary, :limit => 16384
      t.text :long_desc, :limit => 16384, :null => false
      t.text :simplified_language_description, :limit => 16384
      t.integer :target_age_start
      t.integer :target_age_end
      t.string :target_grade_start
      t.string :target_grade_end
      t.integer :description_quality
      t.string :language , :default =>  "en-US", :null => false
      t.string :repository , :default =>  "Bookshare", :null => false
      t.string :credentials
      t.boolean :is_current , :default => false, :null => false
      t.string :creator , :null => false
      t.timestamp :date_approved
      t.references :image , :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :content_models
  end
end
