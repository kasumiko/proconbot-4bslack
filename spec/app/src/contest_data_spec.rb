RSpec.describe 'Contest data' do
  let(:put) do
    [{ body: 'text' }, { body: 'text2' }]
  end

  let(:ans) do
    [{ body: 'text', id: 0 }, { body: 'text2', id: 1 }]
  end

  it 'init' do
    expect(ScheduledContest::ContestData.new(put).data).to eq put
  end
  it 'with_index' do
    expect(ScheduledContest::ContestData.new(put).with_index).to eq ans
  end
  it "with_index data isn't change" do
    sc = ScheduledContest::ContestData.new(put)
    sc.with_index
    expect(sc.data).to eq put
  end
end
