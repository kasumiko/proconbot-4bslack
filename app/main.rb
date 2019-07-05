require 'dotenv'
require 'sinatra'
require 'json'
require 'slack-ruby-client'
require 'rufus-scheduler'
require_relative './src/request_condition.rb'
require_relative './src/random_problem/duel.rb'
require_relative './src/batch/daily_batch.rb'
require_relative './src/batch/force_batch.rb'
require_relative './src/answerers.rb'

Dotenv.load

module Main
  class SlackConnection
    attr_accessor :client
    def initialize
      Slack.configure do |config|
        config.token = ENV['SLACK_API_TOKEN']
      end
      @client ||= Slack::Web::Client.new
    end

    def get_members
      members = {}
      @client.users_list.members.each do |user|
        members[user.id] = user.name
      end
      return members
    end

    def answers(event)
      answerers = Answerers.new
      answerers.objects.each do |obj|
        begin
          ans = obj.answer event['user'], event['text']
          return ans unless ans.to_s.empty?
        rescue => e
          puts e.message.to_s
          return e.message.to_s
        end
      end
      return nil 
    end

    def reply(event)
      content = answers event
      message content unless content.nil?
    end

    def message(arg)
      Main::SlackConnection.new.chat_postMessage(mk_message)
    end

    def mk_message(arg)
      case arg 
      when String
        puts arg
        return {as_user: true, channel: ENV['CHANNEL'], text: arg}
      when Hash
        puts arg[:text]
        return arg 
      end
    end
  end
end

#------------------- Job Scheduler ------------------------
scheduler = Rufus::Scheduler.new
slack = Main::SlackConnection.new
$members = slack.get_members

# scheduler.in '10s' do
scheduler.cron '0 0 * * *' do
  dbatch = Batch::DailyBatch.new
  dbatch.op_batch
end

Batch::ForceBatch.op_batch 'contest_today'

# -------------- Server ----------------
last_event_id = ''

get '/' do
  redirect 'https://github.com/kasumiko/proconbot-4bslack'
end

get '/alive' do
  'alive'
end

post '/callback' do
  body = JSON.parse request.body.read
  event = body['event']
  event_id = body['event_id']
  case body['type']
  when 'url_verification'
    content_type :json
    body.to_json
  when 'event_callback'
    next unless RequestCondition.check event , event_id, last_event_id
    p event
    #p body
    last_event_id = event_id
    slack = Main::SlackConnection.new
    slack.reply event
    'ok'
  end
end

post '/button' do
  RandomProblem::Duel.start
end

post '/force' do
  body = JSON.parse(request.body.read)
  if body['pass'] != ENV['FORCE_PASS']
    'pass is wrong'
  elsif body['type'].nil?
    'type is empty'
  else
    Batch::ForceBatch.op_batch body['type']
  end
end

