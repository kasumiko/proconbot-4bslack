require 'json'
require 'open-uri'
require 'dotenv'
require 'rufus-scheduler'
require_relative '../user_db.rb'

Dotenv.load './config/.env'
class RateCheck
  attr_accessor :users
  def initialize
    @users = ['kasu_miko','Kandam','nesouda']
  end

  def update(rates)
    UserDB::Users.establish_connection(ENV['DATABASE_URL'])
    @db = UserDB::Users
    @db.all.each_with_index{|user,i|
      user.update(
        rate: rate[i][:rate],
        updated_at: rate[i][:updated_at]
      )
    }
  end

  def check_rate(client)
    @client = client
    scheduler = Rufus::Scheduler.new
    @db = UserDB::OperateDB.new(UserDB::Users,'users')
    old_rate = @db.all_data.map{|d|
      d[:rate]
    }
    scheduler.every '1m' , :last_in => 3600*60 do
      new_rate = get_rate
      if comp_rate(old_rate,new_rate) 
        rate_report(old_rate,new_rate)
        update(new_rate)
        return
      end
    end
  end

  def comp_rate(old_rate,new_rate)
    new_rate.each_with_index{|r,i|
      return true if r[:rate] != old_rate[i]
    }
    return false
  end

  def get_rate
    new_data = @users.map{|u|
      (JSON.load URI.parse(make_uri u).open).last
    }
    new_data = symbolize_keys(new_data)
    return new_data.map.with_index{|d,i|
      Hash[
        :id , i,
        :name , @users[i],
        :rate , d[:newrating].to_i,
        :updated_at , Date.today,
        :max_score , 0
      ]
    }
  end

  def make_uri(user_name)
    return "https://atcoder.jp/users/" + user_name + "/history/json"
  end

  def symbolize_keys(hash_a)
    hash_a.map{|hash|hash.map{|k,v|[k.downcase.to_sym,v]}.to_h}
  end

  def rate_report(old_rate,new_rate)
    text = "レートが更新されました。\n"
    p new_rate
    new_rate.each_with_index do|n,i|
      if n[:id] != old_rate[i] 
        diff = n[:rate] - old_rate[i]
        text += n[:name]
        text += "  #{old_rate[i]} => #{n[:rate]} ("
        text += diff > 0 ? '+' : ''
        text += "#{diff})\n"
      end
    end
#    @client.message channel: ENV['CHANNEL'], text: text
    puts text
  end
=begin
  def create
    rate_data = get_rate_data
    p user_data
    @db = UserDB::OperateDB.new(UserDB::Users,'users')
    @db.reflesh_data(UserDB::Users,user_data)
    p @db.get_all_data.to_hash
  end
=end
end

#rate = RateCheck.new
#rate.check_rate(0)