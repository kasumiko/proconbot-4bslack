require_relative './judge.rb'

module RandomProblem
  class Duel
    def initialize; end

    class << self
      def start
        @@during_duel ||= false
        return 'すでに開始しています。' if @@during_duel == true
        @users = %w[kasu_miko Kandam nesouda]
        ans = RandomProblem::Answerer.new
        solved = []
        @users.each { |u|
          solved |= ans.get_json ans.submission + u
        }
        ans.solved_problem = solved
        ans.max_score = 400
        @prob = ans.choose_problem
        post
        @@during_duel = true
        timer
        ''
      end

      def post
        text = @prob['contest_id'].upcase + ' ' + @prob['title'] + "\n"
        text += '制限時間' + case @prob['point']
                         when 100
                           "5分\n"
                         when 200
                           "10分\n"
                         when 300
                           "20分\n"
                         when 400
                           "60分\n"
                         else
                           "error\n"
                         end
        text += mk_prob_url
        text += "\nで勝負！"
        Main::SlackConnection.new.message text
      end

      def timer
        limit = case @prob['point'].to_i
                when 100
                  60 * 5
                when 200
                  60 * 10
                when 300
                  60 * 20
                when 400
                  60 * 60
                end
        s = Rufus::Scheduler.new
        s.in limit do
          Main::SlackConnection.new.message '終了！'
          Judge.judge(@prob, @users, limit)
          @@during_duel = false
        end
      end

      def mk_prob_url
        ret = 'https://Atcoder.jp/contests/'
        ret += @prob['contest_id']
        ret += '/tasks/'
        ret += @prob['id']
        return ret
      end
    end

    def answer(*query)
      return unless query[1] == 'duel'
      return {
        as_user: true,
        channel: ENV['CHANNEL'],
        text: 'デュエルしようぜ',
        attachments: [
          {
            text: 'Startを押すと開始します。',
            fallback: 'fallback',
            callback_id: 'callback_id',
            attachment_type: 'default',
            actions: [
              {
                name: 'Start',
                text: 'Start',
                type: 'button',
                value: 'start'
              }
            ]
          }
        ]
      }
    end
  end
end
