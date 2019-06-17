require 'active_record'
require 'time'
require_relative './OperateDB'

module UserDB
  class Users < ActiveRecord::Base
  end

  class OperateDB < OperateDB
    def format_results(hash_a)
      return hash_a.map{|hash|
        hash[:id] =  hash[:id].to_i
        hash[:rate] =  hash[:rate].to_i
        hash[:max_score] =  hash[:max_score].to_i
        hash[:updated_at] =  Date.strptime(hash[:updated_at],"%Y-%m-%d")
        hash
      }
    end
  end
end