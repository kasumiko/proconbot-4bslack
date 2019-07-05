require_relative '../contest_info.rb'
require_relative './rate_check.rb'
require_relative './daily_batch.rb'
require_relative '../scheduled_contest/update_schedule.rb'
require_relative '../scheduled_contest/scheduled_contest_db.rb'

module Batch
  class ForceBatch
    def self.op_batch(type)
      case type
      when 'contest_today'
        obj = Batch::DailyBatch.new
        obj.contest_today?
        'contest_today'
      when 'rate_check'
        obj = Batch::DailyBatch.new
        obj.check_schedule
        obj.rate_check_start
        'rate_check'
      when 'force_rate_check'
        obj = RateCheck.new
        obj.check_rate
        'force_rate_check'
      when 'update_db'
        obj = Batch::DailyBatch.new
        obj.update_db
        'update_db'
      when 'only_update_db'
        obj = ScheduledContest::ScheduledContest.new
        obj.update
        'update_db'
      else
        'invalid type was passed!'
      end
    end
  end
end
