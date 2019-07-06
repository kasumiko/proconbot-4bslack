RSpec.describe 'Event test' do
  let(:body) do
    {
      'client_msg_id' => '55d52e04-7713-4731-b3a2-8b770d7051fd',
      'type' => 'message',
      'text' => 'こん',
      'user' => 'UKMMK9KQX',
      'ts' => Time.now.to_f.to_s,
      'team' => 'TKDFGV57T',
      'channel' => 'CKKS3E96U',
      'event_ts' => Time.now.to_f.to_s,
      'channel_type' => 'channel'
    }
  end

  let(:ans) do
    true
  end

  it 'true' do
    expect(RequestCondition.check(body,'a','b')).to eq true
  end
  it 'time false' do
    body['ts'] = (body['ts'].to_f - 11.0).to_s
    expect(RequestCondition.check(body,'a','b')).to eq false
  end
end
