class CreateDescriptions < ActiveRecord::Migration
  def self.up
    create_table :descriptions do |t|
      t.string :description , :limit => 16384, :null => false
      t.boolean :is_current , :default => false, :null => false
      t.string :submitter , :default =>  "anonymous", :null => false
      t.timestamp :date_approved
      t.references :image , :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :descriptions
  end
end
