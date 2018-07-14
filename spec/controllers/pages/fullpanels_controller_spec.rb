# frozen_string_literal: true

RSpec.describe Pages::FullpanelsController do
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #case1" do
    it "returns http success" do
      get :case1
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #case2" do
    it "returns http success" do
      get :case2
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #case3" do
    it "returns http success" do
      get :case3
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #case4" do
    it "returns http success" do
      get :case4
      expect(response).to have_http_status(:success)
    end
  end
end
