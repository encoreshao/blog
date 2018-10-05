# frozen_string_literal: true

RSpec.describe Admin::TagsController do
  let(:user) { User.make!(:admin) }
  let(:tag) { Tag.make! }
  before(:each) { sign_in(user) }

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: tag.id }
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
      get :edit, params: { id: tag.id }
      expect(response).to have_http_status(:success)
    end
  end
end
