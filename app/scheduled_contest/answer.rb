require_relative './scheduled_contest_db.rb'
require_relative '../contest_info.rb'
module ScheduledContest
  class Answerer
    def answer(*query)
      user = query[0]
      text = query[1]
      return unless text=~/今週のコンテスト/
      type = "今週"
      return mk_reply(text,type)
    end

    def mk_reply(text,type)
      contests = get_contests_data
      return type + "予定されたコンテストはありません。" if contests == [] 
      ret = type + "予定されたコンテストは\n"
      contests = ContestInfo.new(contests)
      contests.info.each{|contest|ret += contest[:text]}
      ret += "です。"
      return ret
    end
    
    def get_contests_data
      db = OperateDB.new(ScheduledContests,'scheduled_contests')
      return db.all_data
    end
  end
end

#obj = ScheduledContest::Answerer.new()
#puts obj.answer('kasu_miko','今週のコンテスト')