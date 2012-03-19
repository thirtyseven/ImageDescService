class UserSweeper < ActionController::Caching::Sweeper #:nodoc:
  observe UserRole
  
  def before_create(user_role)
     before_save(user_role)
  end

  def before_save(user_role)
   if (controller) # only update roles in admin tool 
    if (user_role.new_record?)
     raise Exception.new("Unathorized access - Assigning roles outside of the admin tool")
    end
   end  
  end
  
end