require 'open-uri'
require 'nokogiri'
require 'rexml/document'

module RandomProblem
  class Judge
    class << self
      def judge(prob, users, limit)
        @prob = prob
        @users = users
        @end_t = Time.now
        scores = @users.map { |user|
          submits = scrape_submit mk_submit_url user
          next [0, user] if submits == []
          format_submits submits
          score = calc_score submits, limit
          [score, user]
        }
        post_result mk_ranking scores
      end

      def mk_ranking(scores)
        text = ''
        scores.sort.reverse.each_with_index { |score, i|
          if score[0].positive?
            text += "#{i + 1}位は#{score[1]}さん\n"
          end
        }
        return '誰も時間内にACできませんでした…' if text == ''
        return text += 'でした。お疲れ様でした！'
      end

      def post_result(text)
        mes = Main::Main.new
        mes.message(as_user: true, channel: ENV['CHANNEL'], text: text)
      end

      def format_submits(submits)
        submits.each { |submit|
          submit[0] = Time.parse(submit[0]).to_i
        }
      end

      def calc_score(submits, limit)
        score = 0
        submits.each { |submit|
          return score if submit[0] < @end_t.to_i - limit
          case submit[1]
          when 'WA'
            score += 5 * 60
          when 'AC'
            return score + @end_t.to_i - submit[0]
          end
        }
      end

      def scrape_submit(url)
        xpath = ['//tr//td[1]', '//tr//td[7]']
        parsed = parse_page url, xpath
        return parsed[0].map.with_index { |p, i| [p.text, parsed[1][i].text] }.reverse
      end

      def get_page(url)
        return Nokogiri::HTML.parse(URI.parse(url).open, nil, 'utf-8')
      end

      def parse_page(url, xpaths)
        doc = get_page(url)
        ret = xpaths.map { |xp|
          doc.xpath(xp)
        }
        return ret
      end

      def mk_submit_url(user)
        ret = 'https://atcoder.jp/contests/'
        ret += @prob['contest_id']
        ret += '/submissions?f.Task='
        ret += @prob['id']
        ret += '&f.Language=&f.Status=&f.User='
        ret += user
        ret
      end
    end
  end
end
