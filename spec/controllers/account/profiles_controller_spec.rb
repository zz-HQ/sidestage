require 'spec_helper'
require 'before_each_helper'

describe Account::ProfilesController, :type => :controller do
  
  before_each
  before(:each) do
    FactoryGirl.create(:genre_classic)
    FactoryGirl.create(:genre_pop)
    FactoryGirl.create(:genre_dj)
    FactoryGirl.create(:genre_country)
  end
  
  it "redirects index to new" do
    sign_in(FactoryGirl.create(:user))
    get :index
    expect(response).to redirect_to(new_account_profile_path)    
  end
  
  
  context "new" do
    it "renders new" do
      sign_in(FactoryGirl.create(:user))
      get :new
      expect(response).to render_template(:new)
    end
    
    it "redirects new to show" do
      profile = FactoryGirl.create(:profile)
      sign_in(profile.user)    
      get :new
      expect(response).to redirect_to(account_profile_path(profile))
    end
  end
  
  it "gets show" do
    profile = FactoryGirl.create(:profile)
    sign_in(profile.user)    
    get :show, id: profile.to_param
    
    expect(response).to render_template(:show)
  end
  
end
