class CreateDynamicDescriptions < ActiveRecord::Migration
  def self.up
    create_table :dynamic_descriptions do |t|
      t.string :body , :limit => 16384, :null => false
      t.boolean :is_current , :default => false, :null => false
      t.string :submitter , :default =>  "anonymous", :null => false
      t.timestamp :date_approved
      t.references :dynamic_image , :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :dynamic_descriptions
  end
end
