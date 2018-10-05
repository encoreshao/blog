# frozen_string_literal: true

RSpec.describe Admin::CategoriesController do
  let(:user) { User.make!(:admin) }
  let(:category) { Category.make! }
  before(:each) { sign_in(user) }

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: category.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      get :edit, params: { id: category.id }
      expect(response).to have_http_status(:success)
    end
  end
end
