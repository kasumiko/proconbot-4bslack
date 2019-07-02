require 'active_record'
require 'time'
require_relative './operate_db'

module UserDB
  class Users < ActiveRecord::Base
    self.default_timezone = :local
  end

  class OperateDB < OperateDB
    def make_table_vars
      @dbclass = Users
      @table_name = 'users'
    end
    def format_results(hash_a)
      return hash_a.map { |hash|
        hash[:id] = hash[:id].to_i
        hash[:rate] = hash[:rate].to_i
        hash[:max_score] = hash[:max_score].to_i
        hash[:updated_at] = Date.strptime(hash[:updated_at], '%Y-%m-%d')
        hash
      }
    end
  end
end
