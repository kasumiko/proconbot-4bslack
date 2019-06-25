require 'slack-ruby-client'
require 'dotenv'
require 'rufus-scheduler'
require_relative '../contest_info.rb'
require_relative './rate_check.rb'
require_relative '../scheduled_contest/update_schedule.rb'
require_relative '../scheduled_contest/scheduled_contest_db.rb'
Dotenv.load './config/.env'

module Batch
  class DailyBatch
    def initialize(client)
      @client = client
      @schedule = ScheduledContest::ScheduledContest.new
    end
    def op_batch
      update_db
      contest_today?
    end

    def update_db
      update_report(@schedule.update)
    end

    def update_report(new_contests)
      return if new_contests == [] 
      text = "コンテスト予定が更新されました。\n"
      @conts = ContestInfo.new(new_contests)
      @conts.info.each{|c|
        text += c[:text]
      }
      @client.message channel: ENV['CHANNEL'], text: text
      puts text
    end

  # gabagaba
    def contest_today?
      today = Date.today
      contests = ScheduledContest::OperateDB.new(ScheduledContest::ScheduledContests,'scheduled_contests')
      text = "今日は以下のコンテストが予定されています。\n"
      flag = false
      times = []
      p contests.all_data
      conts = ContestInfo.new(contests.all_data)
      conts.info.each{|c|
        if c[:start_date] == today
          text += c[:text]
          times << c[:end_time]
          flag = true
        end
      } 
      return if flag == false
      @client.message channel:ENV['CHANNEL'], text: text     
      times.each{|t|
        schedule = Rufus::Scheduler.new 
        scheduler.at t.to_s do
          r = RateCheck.new 
          r.check_rate(@client)
        end
      }
    end
  end
end
=begin
time = Time.strptime("2019-06-25 16:38:15 +0900","%Y-%m-%d %H:%M:%S")
testdata = [
  {:id=>1,:title=>"ABC130",:start_time=>time,:end_time=>time+120,:start_date=>Date.today,:end_date=>Date.today,:url=>"https://atcoder.jp"},
  {:id=>2,:title=>"ABC131",:start_time=>time,:end_time=>time+60,:start_date=>Date.today,:end_date=>Date.today,:url=>"https://atcoder.jp"}
]

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

Slack::RealTime::Client.config do |config|
  config.websocket_ping = 15
end
@client = Slack::RealTime::Client.new()

@client.on :open do 
  p 'open'
end

@client.on :message do |data|
  batch = Batch::DailyBatch.new(@client)
  #batch.update_report(testdata)
  batch.contest_today?
end
@client.start!
=end