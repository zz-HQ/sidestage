class Account::ProfilesController < Account::ResourcesController

  #
  # Settings
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  # 
  
  #
  # Actions
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  def index
    redirect_to new_resource_path
  end
  
  def new
    redirect_to preview_account_profile_path(begin_of_association_chain.profiles.first) and return if begin_of_association_chain.profiles.first.present?
    new!
  end

  def create
    create! do |success, failure|
      success.html {redirect_to pricing_account_profile_path(resource) }
    end
  end
  
  def basics
    resource.wizard_step = :basics
    if request.patch?
      if resource.update_attributes(permitted_params[:profile])
        redirect_to description_account_profile_path(resource)
      end
    end
  end
    
  def description
    resource.wizard_step = :description
    if request.patch?
      if resource.update_attributes(permitted_params[:profile])
        redirect_to pricing_account_profile_path(resource)
      end
    end
  end

  def pricing
    resource.wizard_step = :pricing      
    if request.patch?
      resource.update_attributes(permitted_params[:profile])
    end    
  end 
  
  def toggle
    resource.toggle!
    if resource.published?
      flash[:auto_modal]  = "account/profiles/share_modal"
      redirect_to artist_path(resource)
    else
      flash[:error] = t(:"flash.account.profiles.toggle.alert", edit_profile_path: basics_account_profile_path) if resource.errors.present?
      redirect_to preview_account_profile_path(resource)
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
    params.permit(profile: [:avatar, :solo, :location, :title, :name, :currency, :price, :about, :youtube, :facebook, :twitter, :soundcloud, :availability, :travel_costs, :bic, :iban, genre_ids: []])
  end 
  
  #
  # Private
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  private
  
end