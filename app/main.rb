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

Slack::RealTime::Client.config do |config|
  config.websocket_ping = 15 
  config.websocket_proxy = '0.0.0.0:' + ENV['PORT']
end
client = Slack::RealTime::Client.new

$members = Hash.new
client.web_client.users_list.members.each do |user|
    $members[user.id] = user.name
end
p $members

#------------------- Job Scheduler ------------------------
scheduler = Rufus::Scheduler.new

scheduler.in '10s' do
#scheduler.cron '0 0 * * *' do
  dbatch = Batch::DailyBatch.new(client.web_client)
  dbatch.op_batch
end

# -------------- RTM Server -------------------------

client.on :open do
  p 'opened'
end

objs = [
  ScheduledContest::Answerer.new,
  RandomProblem::Answerer.new
]

client.on :message do |data|
  next if data.user == ENV['BOT_SLACK_ID'] || data.user.nil? || data.text.nil?
  p data
  ans = nil
  objs.each do |obj|
    ans = obj.answer(data.user, data.text)
    unless ans.nil? 
      client.message channel: data.channel, text: ans 
      p data.channel
      break
    end
  end
  case data.text
  when 'こん'
    client.message channel: data.channel, text: 'こん'
    ans = 'こん'
  end
  p ans
end

client.on :closed do
  puts 'Connection has been disconnected.'
  # @client.start!
end

client.start!