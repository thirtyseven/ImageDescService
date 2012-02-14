ActiveAdmin.register User do
  menu :if => proc{ can? :admin_user, @all }
  scope_to :current_library, :association_method => :related_users
 
  form do |f|
      f.inputs "User Details" do
      f.input :username
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :subject_expertises, :label => 'Subject Matter Expertises', :as => :select, :collection =>  SubjectExpertise.all.map {|subject| [subject.name, subject.id]}, :include_blank => nil
      f.input :other_subject_expertise, :label => 'Other Expertise'
      f.input :password
      f.input :password_confirmation      
      f.input :libraries, :as => :select, :collection => Library.all.map {|library| [library.name, library.id]}, :include_blank => nil, :multiple => false
      # dropdown of roles
      f.input :roles, :as => :select, :collection => Role.all.map {|role| [role.name, role.id]}, :include_blank => nil
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
    column :email
    column "Library" do |user|
      User.connection.select_value "select group_concat(libraries.name separator ' ') from user_libraries, libraries where 
           user_libraries.user_id = #{user.id} and user_libraries.library_id = libraries.id"
      end
    column "Role" do |user|
      User.connection.select_value "select group_concat(roles.name separator ' ') from user_roles, roles where 
           user_roles.user_id = #{user.id} and user_roles.role_id = roles.id"
    end
    default_actions
  end
  
  filter :user_libraries_library_id, :as => :select, :collection => proc { Library.all}, :label => 'Library'
  filter :user_roles_role_id, :as => :select, :collection => proc { Role.all}, :label => 'Role'
  filter :username
  filter :email
  filter :user_subject_expertises_subject_expertise_id, :as => :select, :collection => proc { SubjectExpertise.all}, :label => 'Subject Matter Expertise'
  filter :other_subject_expertise
  
  show do
      attributes_table :id do 
                        row ("First Name") { user.first_name }
                        row ("Last Name") { user.last_name }
                        row ("Username") { user.username }
                        row ("Subject Matter Expertise") {  User.connection.select_value "select group_concat(subject_expertises.name separator ', ') from user_subject_expertises, subject_expertises where 
                               user_subject_expertises.user_id = #{user.id} and user_subject_expertises.subject_expertise_id = subject_expertises.id"}
                        row ("Other Expertise") { user.other_subject_expertise }
                        row ("Email") { user.email }
                        row ("Library") { User.connection.select_value "select group_concat(libraries.name separator ', ') from user_libraries, libraries where 
                                 user_libraries.user_id = #{user.id} and user_libraries.library_id = libraries.id"}
                        row ("Role") { User.connection.select_value "select group_concat(roles.name separator ', ') from user_roles, roles where 
                               user_roles.user_id = #{user.id} and user_roles.role_id = roles.id"}    
      end
  end
  
end

