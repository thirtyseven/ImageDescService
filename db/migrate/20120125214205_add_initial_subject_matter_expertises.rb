class AddInitialSubjectMatterExpertises < ActiveRecord::Migration
  def self.up
     ["Math (algebra, geometry, calculus, statistics)", "Science (chemistry, earth science, biology, physics)", "English/Composition", 
       "Technology/Computer Science", "Art/Music", "History", "Social Sciences/Political Science"].each {|name|  SubjectExpertise.create :name => name}  
  end

  def self.down
  end
end
