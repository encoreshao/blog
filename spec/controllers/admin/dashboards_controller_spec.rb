RSpec.describe Admin::DashboardsController do
  let(:user) { User.make!(:admin) }
  before(:each) { sign_in(user) }

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
