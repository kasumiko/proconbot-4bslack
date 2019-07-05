RSpec.describe 'Reply test' do
  let(:body) do
    {
      'client_msg_id' => '55d52e04-7713-4731-b3a2-8b770d7051fd',
      'type' => 'message',
      'text' => 'こん',
      'user' => 'UKMMK9KQX',
      'ts' => '1562363813.006400',
      'team' => 'TKDFGV57T',
      'channel' => 'CKKS3E96U',
      'event_ts' => '1562363813.006400',
      'channel_type' => 'channel'
    }
  end

  let(:true_reply) do
    'こん'
  end

  it 'ReplyForHello' do
    expect(Main::SlackConnection.new.answers(body)).to eq true_reply
  end
end
