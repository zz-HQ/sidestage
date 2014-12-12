class Account::ProfilesController < Account::ResourcesController

  #
  # Settings
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  # 
  
  respond_to :js, :html
  
  
  #
  # Filters
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  # 
  
  before_filter :ensure_resource_exists, except: [:style]

  #
  # Actions
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  def style
    build_resource if current_user.profile.nil?
    resource.wizard_step = :style
    unless request.get?
      resource.update_attributes(permitted_params[:profile])
    end
  end
  
  Profile::WIZARD_STEPS.reject{ |s| s.in?([:style]) }.each do |step|
    define_method step do
      resource.wizard_step = step
      if request.patch?
        resource.wizard_sub_step = permitted_params[:profile].keys.first.to_sym
        resource.update_attributes(permitted_params[:profile])
      end
    end
  end
  
  
  def soundcloud
    resource.wizard_step = :soundcloud
    resource.update_attributes(permitted_params[:profile])
    flash[:error] = resource.errors.messages[:soundcloud].try(:first) if resource.errors.present? 
    redirect_to :back
  end
  
  def youtube
    resource.wizard_step = :youtube
    resource.update_attributes(permitted_params[:profile])
    flash[:error] = resource.errors.messages[:youtube].try(:first) if resource.errors.present? 
    redirect_to :back
  end
  
  def remove_soundcloud
    resource.update_attribute :soundcloud, nil
    redirect_to :back
  end

  def remove_youtube
    resource.update_attribute :youtube, nil
    redirect_to :back
  end
  
  def toggle
    resource.toggle!
    if resource.published?
      flash[:auto_modal]  = "account/profiles/share_modal"
      redirect_to artist_path(resource)
    else
      flash[:error] = t(:"flash.account.profiles.toggle.alert", edit_profile_path: basics_account_profile_path) if resource.errors.present?
      redirect_to preview_account_profile_path
    end
  end

  #
  # Protected
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  protected
  
  def permitted_params
    params.permit(profile: [:avatar, :artist_type, :currency, :location, :latitude, :longitude, :country_short, :country_long, :title, :name, :price, :about, :youtube, :facebook, :twitter, :soundcloud, genre_ids: []])
  end 
  
  #
  # Private
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  private
  
  def resource
    get_resource_ivar || set_resource_ivar(begin_of_association_chain.profile)
  end  
  
  def ensure_resource_exists
    redirect_to action: :style if current_user.profile.nil?
  end
  
end
