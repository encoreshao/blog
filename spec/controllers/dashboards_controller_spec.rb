# frozen_string_literal: true

RSpec.describe DashboardsController do
  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
