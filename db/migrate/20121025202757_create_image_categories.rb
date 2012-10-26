class CreateImageCategories < ActiveRecord::Migration
  def self.up
    create_table :image_categories do |t|
      t.string :name, :null =>false
      t.string :sample_file_name
      t.timestamps
    end
     
    [["Bar Chart", "image-categories/bar_chart.html"], ["Line Graph", "image-categories/line_graph.html"], ["Venn Diagram", "image-categories/venn_diagram.html"], ["Scatter Plot", "image-categories/scatter_plot.html"], ["Table", "image-categories/table.html"], ["Pie Chart", "image-categories/pie_chart.html"],["Flow Chart", "image-categories/flow_chart.html"], ["Standard Diagram or Illustration", "image-categories/standard_diagram.html"], ["Complex Diagram or Illustration", "image-categories/complex_diagram.html"], ["Math Equations", "image-categories/math_equations.html"] ].each {|cat|  ImageCategory.create :name => cat[0],  :sample_file_name =>cat[1]}   
     add_column :dynamic_images, :image_category_id, :integer
      
  end

  def self.down
    drop_table :image_categories
  end
end
