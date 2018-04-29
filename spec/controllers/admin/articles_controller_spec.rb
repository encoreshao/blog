# frozen_string_literal: true

RSpec.describe Admin::ArticlesController do
  let(:user) { User.make!(:admin) }
  before(:each) do
    @article = Article.make!
    sign_in(user)
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      # get :show
      # expect(response).to have_http_status(:success)
    end
  end

  describe "GET #edit" do
    it "returns http success" do
      # get :edit, id: @article.id
      # expect(response).to have_http_status(:success)
    end
  end
end
