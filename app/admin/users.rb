ActiveAdmin.register User do
  menu :if => proc{ can? :admin_user, @all }
  
  form do |f|
      f.inputs "User Details" do
      f.input :username
      f.input :first_name
      f.input :last_name
      f.input :address
      f.input :geo_city, :label => "City"
      f.input :geo_state, :label => "State"
      f.input :zip_code
      f.input :email
      f.input :telephone
      f.input :subject_expertises, :label => 'Subject Matter Expertises', :as => :select, :collection =>  SubjectExpertise.all.map {|subject| [subject.name, subject.id]}, :include_blank => nil
      f.input :other_subject_expertise, :label => 'Other Expertise'
      f.input :password
      f.input :password_confirmation      
      # dropdown of roles
      f.input :roles, :as => :select, :collection => Role.all.map {|role| [role.name, role.id]}, :include_blank => nil
      f.input :bookshare_volunteer, :as => :select, :collection =>  {'true' => 1, 'false' => 0}, :include_blank => nil
    end
    f.buttons
  end
  

  index do
    column :id
    column :first_name
    column :last_name
    column :username
    column  "Subject Matter Expertise" do |user| 
      User.connection.select_value "select group_concat(subject_expertises.name separator ', ') from user_subject_expertises, subject_expertises where 
           user_subject_expertises.user_id = #{user.id} and user_subject_expertises.subject_expertise_id = subject_expertises.id"     
    end
    column "Other Expertise", :other_subject_expertise
    column :address
    column "City", :geo_city
    column "State", :geo_state
    column :zip_code
    column :email
    column :telephone
    column "Role" do |user|
      User.connection.select_value "select group_concat(roles.name separator ' ') from user_roles, roles where 
           user_roles.user_id = #{user.id} and user_roles.role_id = roles.id"
    end
    column "Bookshare Volunteer", :bookshare_volunteer
    default_actions
  end
  
  filter :user_roles_role_id, :as => :select, :collection => proc { Role.all}, :label => 'Role'
  filter :username
  filter :email
  filter :user_subject_expertises_subject_expertise_id, :as => :select, :collection => proc { SubjectExpertise.all}, :label => 'Subject Matter Expertise'
  filter :other_subject_expertise
  filter :bookshare_volunteer, :as => :select, :collection =>  {'true' => 1, 'false' => 0}
  
  show do
      attributes_table :id do 
                        row ("First Name") { user.first_name }
                        row ("Last Name") { user.last_name }
                        row ("Username") { user.username }
                        row ("Subject Matter Expertise") {  User.connection.select_value "select group_concat(subject_expertises.name separator ', ') from user_subject_expertises, subject_expertises where 
                               user_subject_expertises.user_id = #{user.id} and user_subject_expertises.subject_expertise_id = subject_expertises.id"}
                        row ("Other Expertise") { user.other_subject_expertise }
                        row ("Address") { user.address }
                        row ("City") { user.geo_city }
                        row ("State") { user.geo_state }
                        row ("Zip Code") { user.zip_code }
                        row ("Email") { user.email }
                        row ("Telephone") { user.telephone }    
                        row ("Role") { User.connection.select_value "select group_concat(roles.name separator ', ') from user_roles, roles where 
                               user_roles.user_id = #{user.id} and user_roles.role_id = roles.id"}    
                        row ("Bookshare Volunteer") { user.bookshare_volunteer}                        
      end
  end
  
end

