class Admin::UsersController < Admin::ResourcesController
  
  
  #
  # Actions
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  def confirm
    resource.confirm!
    redirect_to :back  
  end
  
  def toggle_verification
    resource.update_attribute :verified, !resource.verified?
    redirect_to :back 
  end
  
  def backdoor
    sign_out(:user)
    warden.request.env['devise.skip_trackable'] = true
    sign_in(resource)
    redirect_to after_sign_in_path_for(resource)
  end
  
end