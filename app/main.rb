require 'dotenv'
require 'sinatra'
require 'json'
require 'slack-ruby-client'
require 'rufus-scheduler'
require_relative './hello.rb'
require_relative './scheduled_contest/answer.rb'
require_relative './random_problem/answer.rb'
require_relative './batch/daily_batch.rb'

Dotenv.load

module Main 
  class Main
    attr_accessor :client
    def initialize
      Slack.configure do |config|
        config.token = ENV['SLACK_API_TOKEN']
      end
      @client ||= Slack::Web::Client.new
    end

    def get_members
      members = Hash.new
      @client.users_list.members.each do |user|
          members[user.id] = user.name
      end
      return members
    end

    def mk_reply(event)
      user = event['user']
      text = event['text']
      ret = nil
      return if user==ENV['BOT_SLACK_ID'] || user.nil? || text.nil?
      puts user + ' ' + text
      objs = [
        ScheduledContest::Answerer.new,
        RandomProblem::Answerer.new,
        Hello.new
      ]
      objs.each do |obj|
        ans = obj.answer user,text
        begin
          unless ans.nil?
            ret = ans
            break
          end
        rescue => exception
          p exception.message
          ret = "#{exception.message}"
        end
      end
      return ret
    end

    def reply(event)
      text = mk_reply(event)
      return if text == '' || text.nil?
      puts text
      message(text)
    end

    def message(text)
      puts text
      @client.chat_postMessage(
        as_user: 'true',
        channel: ENV['CHANNEL'],
        text: text
      ) 
    end
  end
end

#------------------- Job Scheduler ------------------------
scheduler = Rufus::Scheduler.new
main = Main::Main.new
$members = main.get_members

#scheduler.in '10s' do
scheduler.cron '0 0 * * *' do
  dbatch = Batch::DailyBatch.new 
  dbatch.op_batch
end

# -------------- Server ----------------
last_event_id = ''

get '/' do
  redirect 'https://github.com/kasumiko/proconbot-4bslack'
end

get 'alive' do
  'alive'
end

post '/callback' do
  body = JSON.parse(request.body.read)
  event = body['event']
  event_id = body['event_id']
  case body['type']
  when 'url_verification'
    content_type :json
    body.to_json
  when 'event_callback'
    next if event_id == last_event_id || Time.now.to_f - event['ts'].to_f > 10.0
    p body
    last_event_id = event_id
    main = Main::Main.new
    main.reply(event) 
  'ok'
  end
end