RSpec.describe Hello do
  context 'こん' do
    it 'Return こん' do
      expect(Hello.new.answer('User', 'こん')).to eq 'こん'
    end
  end
  context 'わん' do
    it 'Return nil' do
      expect(Hello.new.answer('User', 'わん')).to eq nil
    end
  end
end
