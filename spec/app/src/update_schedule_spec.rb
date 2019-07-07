RSpec.describe 'update schedule' do
  let(:body) do
    {

    }
  end

  let(:ans) do
    true
  end

  it 'nothing' do
    obj = ScheduledContest::ScheduledContest.new
    expect(obj.update).to eq []
  end
end
