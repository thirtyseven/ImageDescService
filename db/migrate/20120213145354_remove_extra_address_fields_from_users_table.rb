class RemoveExtraAddressFieldsFromUsersTable < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.remove :geo_city
      t.remove :geo_state
      t.remove :zip_code
    end
  end

  def self.down
    change_table :users do |t|
      t.string :geo_city
      t.string :geo_state
      t.string :zip_code
    end
  end
end
