require 'dotenv'
require 'slack-ruby-client'

Dotenv.load
Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

Slack::RealTime::Client.config do |config|
  config.websocket_ping = 30
end

@client = Slack::RealTime::Client.new

@client.on :message do |data|
  break if (data.user=='UKDFHP9A5') 
  case data.text
  when 'こん'
    @client.message channel: data.channel, text: 'こん'
  else

  end
end

@client.on :closed do |data|
  puts 'Connection has been disconnected.'
  @client.start!
end

@client.start!

