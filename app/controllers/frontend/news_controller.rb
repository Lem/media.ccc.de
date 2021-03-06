module Frontend
  class NewsController < FrontendController
    def index
      news = News.all
      atom_feed = Feeds::NewsFeedGenerator.generate(news,
        options: {
          author: Settings.feeds['channel_owner'],
          title: 'CCC TV - NEWS',
          feed_url: news_url,
          icon: File.join(Settings.frontend_url, 'favicon.ico'),
          logo: view_context.image_url('frontend/tv.png')
        })
      respond_to do |format|
        format.xml { render xml: atom_feed }
      end
    end
  end
end
