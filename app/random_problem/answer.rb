require 'json'
require 'open-uri'
require 'active_record'
require 'dotenv'
require_relative '../user_db.rb'

require 'slack-ruby-client'

Dotenv.load './config/.env'
module RandomProblem
  class Answerer
    def initialize
      @contest_info = 'resources/contests.json'
      @problem_info = 'resources/merged-problems.json'
      @submission = 'atcoder-api/results?user='
    end

    def answer(*arg)
      user = arg[0]
      text = arg[1]
      return unless text =~ /問題くれ/
      user = $members[user]
      UserDB::Users.establish_connection(ENV['DATABASE_URL'])
      @db = UserDB::Users
      @users = @db.find_by(slack_name: user)
      @max_score = @users[:max_score].to_i
      @max_score = 100 if @max_score == 0
      user = @users[:atcoder_name]
      @solved_problem = get_json(@submission+user)
      update_max_score
      return mk_reply(choose_problem,user)
    end

    def mk_reply(prob,user)
      text = user + "さんは\n"
      text += prob['contest_id'].upcase + ' ' + prob['title'] + "\n"
      text += mk_url(prob)
      text += "\nを解いてください。"
      return text
    end

    def update_max_score
      new_score = @max_score
      @solved_problem.each do |s|
        next if s['result']!='AC'
        new_score = new_score > s['point'] ? new_score : s['point']
      end
      @users.update(max_score: new_score) if new_score != @max_score
    end

    def mk_url(prob)
      ret = 'https://Atcoder.jp/contests/'
      ret += prob['contest_id']
      ret += "/tasks/"
      ret += prob['id']
      return ret
    end

    def choose_problem
      problems = get_json(@problem_info)
      while true
        prob = problems.sample
        next if prob['point'].nil?
        return prob if (unsolved? prob) && prob['point'] <= @max_score
      end
    end

    def unsolved?(prob)
      @solved_problem.each do |s|
        next if s['result']!='AC'
        return false if s['problem_id'] == prob['id']
      end
      return true
    end

    def convert_id(user)
      user_names = Hash[
        'kasumiko' , 'kasu_miko',
        'tomohiro_kanda' , 'Kandam',
        'nesouda' , 'nesouda'
      ]
      return user_names[user]
    end

    def get_json(query)
      base_uri = 'https://kenkoooo.com/atcoder/' 
      JSON.load URI.parse(base_uri + query).open
    end
  end
end