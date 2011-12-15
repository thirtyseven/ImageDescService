ActiveAdmin.register User do
  
  form do |f|
     f.inputs "Admin Details" do
      f.input :username
      f.input :email
      f.input :password
      f.input :password_confirmation      
      # dropdown of roles
      f.input :roles, :as => :select, :collection => Role.all.map {|role| [role.name, role.id]}, :include_blank => nil
    end
    f.buttons
  end
  
  index do
    column :id
    column :username
    column :email
    default_actions
  end
  
  filter :username
  filter :email
  
  show do
      attributes_table :id, :username, :email
  end
  
end
