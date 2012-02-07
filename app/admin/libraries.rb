ActiveAdmin.register Library do
  menu :if => proc{ can? :admin_user, @all }
  
  form do |f|
     f.inputs "Library Details" do
     f.input :name
    end
    f.buttons
  end
  
  index do
    column :id
    column :name
    default_actions
  end
  
  filter :name
  
  show do
      attributes_table :id,  :name
  end
    
end
