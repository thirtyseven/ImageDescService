ActiveAdmin.register AdminUser do
  #controller.skip_load_resource :only => :index
  #controller.authorize_resource

  menu 

  form do |f|
    f.inputs "Admin Details" do
      f.input :login
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.buttons
  end

  index do
    column :id
    column :login
    column :email
    default_actions
  end
  
  filter :login
  
  show do
      attributes_table :id, :login, :email
  end
  
end

