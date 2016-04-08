require 'spec_helper'

RSpec.describe ActsAsBytefield do
  let(:bytefield_model) { BytefieldModel.create(one: 'ß', two: 'å', three: '3') }

  after(:each) do
    expect(bytefield_model.my_bytefield.length).to eq(3)
  end

  context 'on create' do
    it 'sets single-byte values' do
      expect(bytefield_model.one).to eq('ß')
      expect(bytefield_model.two).to eq('å')
      expect(bytefield_model.three).to eq('3')
    end

    it 'uses first byte in multi-byte values' do
      bytefield_model = BytefieldModel.create(one: 'ßeta', two: 'åsphalt', three: '333')
      expect(bytefield_model.one).to eq('ß')
      expect(bytefield_model.two).to eq('å')
      expect(bytefield_model.three).to eq('3')
    end

    it 'converts integer values to bytes' do
      bytefield_model = BytefieldModel.create(one: 99, two: 2, three: 3)
      expect(bytefield_model.one).to eq('c')
      expect(bytefield_model.two).to eq(2.chr)
      expect(bytefield_model.three).to eq(3.chr)
    end

    it 'ignores invalid keys' do
      expect do
        BytefieldModel.create(bogus: 99)
      end.to raise_error(ActiveRecord::UnknownAttributeError, /unknown attribute 'bogus'/)
    end
  end

  context 'on update' do
    it 'sets single-byte values' do
      bytefield_model.update(one: '1', two: '2', three: '3')
      expect(bytefield_model.one).to eq('1')
      expect(bytefield_model.two).to eq('2')
      expect(bytefield_model.three).to eq('3')
    end

    it 'uses first byte in multi-byte values' do
      bytefield_model.update(one: 'ßeta', two: 'åsphalt', three: '333')
      expect(bytefield_model.one).to eq('ß')
      expect(bytefield_model.two).to eq('å')
      expect(bytefield_model.three).to eq('3')
    end

    it 'converts integer values to bytes' do
      bytefield_model.update(one: 99, two: 2, three: 3)
      expect(bytefield_model.one).to eq('c')
      expect(bytefield_model.two).to eq(2.chr)
      expect(bytefield_model.three).to eq(3.chr)
    end
  end

  context 'on set and save' do
    it 'sets single-byte values' do
      bytefield_model.one = '1'
      bytefield_model.two = '2'
      bytefield_model.three = '3'
      bytefield_model.save
      expect(bytefield_model.one).to eq('1')
      expect(bytefield_model.two).to eq('2')
      expect(bytefield_model.three).to eq('3')
    end

    it 'uses first byte in multi-byte values' do
      bytefield_model.one = 'ßeta'
      bytefield_model.two = 'åsphalt'
      bytefield_model.three = '333'
      bytefield_model.save
      expect(bytefield_model.one).to eq('ß')
      expect(bytefield_model.two).to eq('å')
      expect(bytefield_model.three).to eq('3')
    end

    it 'converts integer values to bytes' do
      bytefield_model.one = 25
      bytefield_model.two = 127
      bytefield_model.three = 65
      bytefield_model.save
      expect(bytefield_model.one).to eq("\u0019")
      expect(bytefield_model.two).to eq("\u007F")
      expect(bytefield_model.three).to eq('A')
    end
  end

  context 'on update_attributes' do
    it 'sets single-byte values' do
      bytefield_model.update_attributes(one: '0', two: '2', three: '3')
      expect(bytefield_model.one).to eq('0')
      expect(bytefield_model.two).to eq('2')
      expect(bytefield_model.three).to eq('3')
    end

    it 'uses first byte in multi-byte values' do
      bytefield_model.update_attributes(one: 'ßeta', two: 'ålpha', three: '333')
      expect(bytefield_model.one).to eq('ß')
      expect(bytefield_model.two).to eq('å')
      expect(bytefield_model.three).to eq('3')
    end

    it 'converts integer values to bytes' do
      bytefield_model.update_attributes(one: 25, two: 127, three: 65)
      expect(bytefield_model.one).to eq("\u0019")
      expect(bytefield_model.two).to eq("\u007F")
      expect(bytefield_model.three).to eq('A')
    end
  end

  context 'updating the original column' do
    it 'sets individual fields' do
      bytefield_model.update_attributes(my_bytefield: "AB\xFF")
      expect(bytefield_model.one).to eq('A')
      expect(bytefield_model.two).to eq('B')
      expect(bytefield_model.three).to eq("\xFF")
    end
  end
end
