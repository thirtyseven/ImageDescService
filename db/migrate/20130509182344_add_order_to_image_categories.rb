class AddOrderToImageCategories < ActiveRecord::Migration
  def self.up
      add_column :image_categories, :order_to_display, :integer
      execute "update image_categories set order_to_display = CASE id
                when 1 then 1
                when 2 then 3
                when 3 then 7
                when 4 then 5
                when 5 then 6
                when 6 then 4
                when 7 then 2
                when 8 then 8
                when 9 then 9 
                when 10  then 10
              end"
  end

  def self.down
  end
end
