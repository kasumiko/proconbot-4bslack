require 'dotenv'
require 'slack-ruby-client'
require 'rufus-scheduler'
require_relative './scheduled_contest/answer.rb'
require_relative './random_problem/answer.rb'
require_relative './batch/daily_batch.rb'

Dotenv.load
Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

http_proxy = '0.0.0.0:' + ENV['PORT']
Slack::RealTime::Client.config do |config|
  config.websocket_ping = 10
  config.websocket_proxy = http_proxy
end
@client = Slack::RealTime::Client.new

#------------------- Job Scheduler ------------------------
scheduler = Rufus::Scheduler.new

scheduler.cron '0 0 * * *' do
  dbatch = Batch::DailyBatch.new(@client)
  dbatch.op_batch
end

# -------------- RTM Server -------------------------

@client.on :open do
  p 'opened'
end

objs = [
  ScheduledContest::Answerer.new,
  RandomProblem::Answerer.new
]
@client.on :message do |data|
  next if data.user == 'UKDFHP9A5'
  #p @client.web_client.users_info('UKMMK9KQX')
  
  case data.text
  when 'こん'
    @client.message channel: data.channel, text: 'こん'
  end
  objs.each do |obj|
    ans = obj.answer(data.user, data.text)
    @client.message channel: data.channel, text: ans unless ans.nil?
    p ans
  end
end

@client.on :closed do
  puts 'Connection has been disconnected.'
  # @client.start!
end

@client.start!
