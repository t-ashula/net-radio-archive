require 'niconico/live/client/search_result'
require 'niconico/live/client/search_filters'

class Niconico
  def live_client
    Live::Client.new(self.agent)
  end

  class Live
    class Client

      def initialize(agent)
        @agent = agent
        @api = API.new(agent)
      end

      def remove_timeshifts(ids)
        post_body = "delete=timeshift&confirm=#{Util::fetch_token(@agent)}"
        if ids.size == 0
          return
        end
        ids.each do |id|
          id = Util::normalize_id(id, with_lv: false)
          # mechanize doesn't support multiple values for the same key in query.
          post_body += "&vid%5B%5D=#{id}"
        end
        @agent.post(
          'http://live.nicovideo.jp/my.php',
          post_body,
          'Content-Type' => 'application/x-www-form-urlencoded'
        )
      end

      def search(keyword, filters = [])
        filter = filters.join('+')
        page = @agent.get(
          'http://live.nicovideo.jp/search',
          track: '',
          sort: 'recent',
          date: '',
          kind: '',
          keyword: keyword,
          filter: filter
        )
        results_dom = page.at('.result-list')
        items = results_dom.css('.result-item')
        search_results = items.map do |item|
          title_dom = item.at('a.title')
          next nil unless title_dom
          id = title_dom.attr(:href).scan(/lv[\d]+/).first
          title = title_dom.text.strip
          description = item.at('.description-text').text.strip
          SearchResult.new(id, title, description)
        end
        search_results.compact
      end
    end
  end
end
