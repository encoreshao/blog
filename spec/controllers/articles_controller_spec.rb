RSpec.describe ArticlesController do
  before :each do
    @article = Article.make!(published_at: '2017-06-06'.to_date, permalink: 'rails5')
  end

  describe "GET #show" do
    it "should route to article" do
      routes_path = {
        "requirements" => {
          "year" => /\d{4}/,
          "month" => /\d{1,2}/,
          "day" => /\d{1,2}/
        },
        "controller"=>"articles",
        "action"=>"show",
        "year"=>"2017",
        "month"=>"6",
        "day"=>"6",
        "permalink"=>"rails5"
      }
      expect(get: article_path(@article.params)).to route_to(routes_path)
    end
  end
end
