class LoadDescriptionsToAudit < ActiveRecord::Migration
  def self.up
    dynamic_descriptions = DynamicDescription.all

    dynamic_descriptions.each do |dyn_description|
        meta_data = []
        meta_data << ['ID', dyn_description.id]
        meta_data << ['body', dyn_description.body]
        meta_data << ['is_current', dyn_description.is_current]
        meta_data << ['date_approved', dyn_description.date_approved]
        meta_data << ['dynamic_image_id', dyn_description.dynamic_image_id]
        meta_data << ['created_at', dyn_description.created_at]
        meta_data << ['updated_at', dyn_description.updated_at]
        meta_data << ['book_id', dyn_description.book_id]
        meta_data << ['summary', dyn_description.summary]
        meta_data << ['simplified_language_description', dyn_description.simplified_language_description]
        meta_data << ['target_age_start', dyn_description.target_age_start]
        meta_data << ['target_age_end', dyn_description.target_age_end]
        meta_data << ['target_grade_start', dyn_description.target_grade_start]
        meta_data << ['target_grade_end', dyn_description.target_grade_end]
        meta_data << ['description_quality', dyn_description.description_quality]
        meta_data << ['submitter_id', dyn_description.submitter_id]
        meta_data << ['language', dyn_description.language]
        meta_data << ['repository', dyn_description.repository]
        meta_data << ['credentials', dyn_description.credentials]
        meta_data << ['annotation', dyn_description.annotation]
        meta_data << ['tactile_src', dyn_description.tactile_src]
        meta_data << ['tactile_tour', dyn_description.tactile_tour]
        meta_data << ['simplified_image_src', dyn_description.simplified_image_src]
        meta_data << ['simplified_image_tour', dyn_description.simplified_image_tour]
        meta_data << ['repository', dyn_description.repository]

        result = execute("insert into audits (auditable_id, auditable_type, associated_id, user_id, user_type, username, action, audited_changes, version, comment, remote_address, created_at) values (null, 'DynamicDescription', null, null, null, null,'migration of description data before the implementation of audit log of changes', '#{meta_data}', 1, null, null, now())")                                        
     end
     
     dynamic_images = DynamicImage.all 
     dynamic_images.each do | image| 
       dynamic_descriptions = DynamicDescription.where(:dynamic_image_id => image.id).order('created_at asc').all
       dynamic_descriptions.pop #remove the last description
       if !dynamic_descriptions.empty?
          dynamic_descriptions.each do |dy_image|
             dy_image.destroy
          end
       end
     end
  
  end

  def self.down

  end
end
