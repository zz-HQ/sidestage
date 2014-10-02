class ArtistsController < ApplicationController
  
  include PageableResource

  #
  # Filters
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  before_filter :reject_scraper, only: [:index]
  before_filter :coerce_params, only: [:index, :show]
  before_filter :redirect_if_unpublished, only: [:show]
  before_filter :record_query, :only_available_cities, only: [:index]
  
  #
  # Settings
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  inherit_resources
  defaults :resource_class => Profile, :instance_name => 'profile'
  actions :index, :show, :new, :create
  respond_to :html, :js
  
  #
  # Actions
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  def create
    build_resource
    
    redirect_to new_city_launch_path and return unless resource.location.blank? || profile_location_supported?
    
    session[:profile] = permitted_params[:profile]
    render :new and return unless resource.valid?
    
    respond_to do |format|
      format.html{ redirect_to new_user_registration_path }
      format.js{
        redirect_to new_city_launch_path
      }
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
  
  #
  # Private
  # ---------------------------------------------------------------------------------------
  #
  #
  #
  #
  
  private

  
  def collection
    get_collection_ivar || set_collection_ivar(resources)
    #get_collection_ivar || set_collection_ivar(resources.page(params[:page] || 1))
  end  
  
  def resources
    end_of_association_chain.filter(params).sorty(params).radial(lat: params[:lat], lng: params[:lng], radius: 36).published
  end

  def permitted_params
    params.permit(profile: [:artist_type, :name, :location, :price, :title, :about, :city, :youtube, :style, :soundcloud, genre_ids: []])
  end
  
  def redirect_if_unpublished
    redirect_to artists_path unless resource.published?
  end

  def only_available_cities
    redirect_to new_city_launch_path if collection.empty?
  end
    
  def reject_scraper
    redirect_to root_path unless (params[:lat].present? && params[:lng].present?) || params[:short_location].present?
  end
  
  def record_query
    if params[:location].present?
      search_query = SearchQuery.find_or_create_by(location: params[:location])
      search_query.location = params[:location]
      search_query.query = params
      search_query.counter = search_query.counter.to_i + 1
      search_query.save
    end
  end
  
  def build_resource
    super.tap do |profile|
      profile.user_id = -1
    end
  end
  
  def profile_location_supported?
    resource.location.downcase.in?(AVAILABLE_LOCATIONS.map(&:last).map { |l| l[:name].downcase })
  end
  
  def coerce_params
    if params[:location].present?
      session[:location_params] = params
    elsif params[:short_location].present?
      fill_params_from(AVAILABLE_LOCATIONS.map(&:last).select { |l| l[:short] == params[:short_location].to_s.downcase }.first)
      session[:location_params] = params
    else
      if (loc_params = session[:location_params]).present?
        fill_params_from(loc_params)
      end
    end
    @location = params[:location]
  end
  
  def fill_params_from(location_params)
    params[:location] = location_params["location"] || location_params[:name]
    params[:lng] = location_params["lng"] || location_params[:lng]
    params[:lat] = location_params["lat"] || location_params[:lat]
  end

end

