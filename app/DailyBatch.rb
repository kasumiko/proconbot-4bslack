require 'slack-ruby-client'
require 'dotenv'
require_relative 'ContestInfo.rb'
Dotenv.load './config/.env'

class DailyBatch
  def initialize(client)
    @client = client
    @schedule = ScheduledContest.new
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
    text = "今日は以下のコンテストが予定されています。\n"
    flag = false
    @conts.info.each{|c|
      text += c[:text] if c[:start_date] == today
      flag = true
    } 
    @client.message channel:ENV['CHANNEL'], text: text unless flag == true
  end
end


time = Time.strptime("2019-06-20 16:38:15 +0900","%Y-%m-%d %H:%M:%S")
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


@client.on :message do |data|
  batch = DailyBatch.new(@client)
  batch.update_report(testdata)
  batch.contest_today?
end
@client.start!
