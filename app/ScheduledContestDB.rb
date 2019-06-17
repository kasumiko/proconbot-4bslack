require 'time'
require 'active_record'
require 'dotenv'
require_relative './OperateDB.rb'

Dotenv.load './config/.env'
module ScheduledContestDB
  class ScheduledContests < ActiveRecord::Base #same as table name
  end

  class OperateDB < OperateDB
    attr_accessor :all_data
    def format_results(hash_a)
      return hash_a.map{|hash|
        hash[:id] =  hash[:id].to_i
        hash[:start_time] =  Time.strptime(hash[:start_time],"%Y-%m-%d %H:%M:%S")
        hash[:end_time] =  Time.strptime(hash[:end_time],"%Y-%m-%d %H:%M:%S")
        hash[:start_date] =  Date.strptime(hash[:start_date],"%Y-%m-%d")
        hash[:end_date] =  Date.strptime(hash[:end_date],"%Y-%m-%d")
        hash
      }
    end

  end
end
#time = Time.strptime("2019-06-17 16:38:15 +0900","%Y-%m-%d %H:%M:%S")
#testdata = [
#  {:id=>1,:title=>"ABC130",:start_time=>time,:end_time=>time,:start_date=>Date.today,:end_date=>Date.today,:url=>"https://atcoder.jp"},
#  {:id=>2,:title=>"ABC131",:start_time=>time+1,:end_time=>time+1,:start_date=>Date.today,:end_date=>Date.today,:url=>"https://atcoder.jp"}
#]

#obj = ScheduledContestDB::OperateDB.new(ScheduledContestDB::ScheduledContests,'scheduled_contests')
#p obj.get_all_data
#obj.update_data(ScheduledContests,testdata) if obj.all_data.eql?(testdata) 