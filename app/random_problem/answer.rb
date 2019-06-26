require 'json'
require 'open-uri'

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
      user = 'kasu_miko'
      return unless text =~ /問題くれ/
      @max_score = 400
      @solved_problem = get_json(@submission+user)
      return mk_reply(choose_problem,user)
    end

    def mk_reply(prob,user)
      text = user + "さんは\n"
      text += prob['contest_id'].upcase + ' ' + prob['title'] + "\n"
      text += mk_url(prob)
      text += "\nを解いてください。"
      return text
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