class News
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title
  field :content
  field :category

  def self.find_by_category
    map = %Q{
      function() {
        emit(this.category, {news: this});
      }
    }

    reduce = %Q{
      function(key, values) {
        results = {};
        results[key] = [];
        values.forEach(function(value){
          results[key].push(value);
        });
        return results;
      }
    }
    news = News.map_reduce(map, reduce).out(inline: 1)
    return news
  end
end
