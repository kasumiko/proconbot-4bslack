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
      @contests = ScheduledContest::ScheduledContest.new
    end

    def op_batch
      update_db
      contest_today?
    end

    def update_db
      update_report(@contests.update)
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

    def check_schedule
      text = ''
      today = Date.today
      contests = ScheduledContest::OperateDB.new
      @endtimes = []
      conts = ContestInfo.new(contests.all_data)
      conts.info.each { |c|
        next unless c[:start_date] == today
        text += c[:text]
        @endtimes << c[:end_time]
      }
      return text
    end

    def contest_today?
      text = "今日は以下のコンテストが予定されています。\n"
      schetext = check_schedule
      return if schetext == ''
      report(text + schetext)
      rate_check_start
    end

    def rate_check_start
      @endtimes.each { |t|
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
