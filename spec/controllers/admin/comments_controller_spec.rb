# frozen_string_literal: true

RSpec.describe Admin::CommentsController do
  let(:user) { User.make!(:admin) }
  let(:comment) { Comment.make! }
  before(:each) { sign_in(user) }

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: comment.id }
      expect(response).to have_http_status(:success)
    end
  end
end
