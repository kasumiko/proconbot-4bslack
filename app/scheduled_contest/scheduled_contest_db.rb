require 'time'
require 'active_record'
require 'dotenv'
require_relative '../operate_db.rb'

Dotenv.load './config/.env'
module ScheduledContest
  class ScheduledContests < ActiveRecord::Base
    # same as table name
    self.default_timezone = :local
  end

  class OperateDB < OperateDB
    attr_accessor :all_data
    def make_table_vars
      @dbclass = ScheduledContests
      @table_name = 'scheduled_contests'
    end

    def format_results(hash_a)
      return hash_a.map { |hash|
        hash[:id] = hash[:id].to_i
        hash[:start_time] = Time.strptime(hash[:start_time], '%Y-%m-%d %H:%M:%S')
        hash[:end_time] = Time.strptime(hash[:end_time], '%Y-%m-%d %H:%M:%S')
        hash[:start_date] = Date.strptime(hash[:start_date], '%Y-%m-%d')
        hash[:end_date] = Date.strptime(hash[:end_date], '%Y-%m-%d')
        hash
      }
    end
  end
end
