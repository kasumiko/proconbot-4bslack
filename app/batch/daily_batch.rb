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
    def initialize
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
      @conts.info.each { |c|
        text += c[:text]
      }
      report(text)
      puts text
    end

    def contest_today?
      today = Date.today
      dbclass = ScheduledContest::ScheduledContests
      contests = ScheduledContest::OperateDB.new(dbclass, 'scheduled_contests')
      text = "今日は以下のコンテストが予定されています。\n"
      flag = false
      times = []
      conts = ContestInfo.new(contests.all_data)
      conts.info.each { |c|
        next unless c[:start_date] == today
        text += c[:text]
        times << c[:end_time]
        flag = true
      }
      return unless flag
      report(text)
      times.each { |t|
        schedule = Rufus::Scheduler.new
        schedule.at t.to_s do
          puts 'rate check set'
          r = RateCheck.new
          r.check_rate
        end
      }
    end

    def report(text)
      return if text.nil?
      messenger = Main::Main.new
      messenger.message(text)
    end
  end
end
=begin
time = Time.strptime('2019-06-26 16:38:15 +0900', '%Y-%m-%d %H:%M:%S')
testdata = [
  { id: 1, title: 'ABC130', start_time: time, end_time: time + 120, start_date: Date.today, end_date: Date.today, url: 'https://atcoder.jp' },
  { id: 2, title: 'ABC131', start_time: time, end_time: time + 60, start_date: Date.today, end_date: Date.today, url: 'https://atcoder.jp' }
]

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

Slack::RealTime::Client.config do |config|
  config.websocket_ping = 15
end
@client = Slack::RealTime::Client.new

@client.on :open do
  p 'open'
end

@client.on :message do |_data|
  batch = Batch::DailyBatch.new(@client)
  #   batch.update_report(testdata)
  batch.contest_today?(testdata)
end
@client.start!
=end