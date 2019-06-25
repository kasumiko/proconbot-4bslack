require 'dotenv'
require 'slack-ruby-client'
require 'rufus-scheduler'
require_relative './scheduled_contest/answer.rb'
require_relative './batch/daily_batch.rb'

Dotenv.load
Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

http_proxy="0.0.0.0:"+ENV['PORT']
Slack::RealTime::Client.config do |config|
  config.websocket_ping = 15
  config.websocket_proxy = http_proxy
end
@client = Slack::RealTime::Client.new()


#------------------- Job Scheduler ------------------------
scheduler = Rufus::Scheduler.new


#scheduler.cron '15 0 * * *' do
scheduler.in '3m' do
  dbatch = Batch::DailyBatch.new(client)
  dbatch.op_batch
end

# -------------- RTM Server -------------------------

@client.on :open do |data|
  p 'opened'
end


objs = [
  ScheduledContest::Answerer.new
]

@client.on :message do |data|
  break if (data.user=='UKDFHP9A5') 
  case data.text
  when 'こん'
    @client.message channel: data.channel, text: 'こん'
  else
  end
  objs.each{|obj|
    ans = obj.answer(data.user,data.text)
    @client.message channel: data.channel, text: ans if ans != nil
    p ans
  }
end
@client.on :closed do |data|
  puts 'Connection has been disconnected.'
  @client.start!
end
@client.start!
