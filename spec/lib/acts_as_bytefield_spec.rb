require 'spec_helper'

RSpec.describe ActsAsBytefield do
  shared_examples('with these values') do |options|
    after(:each) do
      expect(bytefield_model.my_bytefield.length).to eq(3)
    end

    options.fetch(:original_values).each do |key, value|
      let(key) { value }
    end

    let(:bytefield_model) do
      BytefieldModel.create(options.fetch(:original_values))
    end

    context 'on create' do
      it 'sets expected values' do
        options.fetch(:original_values).each do |key, value|
          expect(
            bytefield_model.send(key)
          ).to eq(value.is_a?(Fixnum) ? value.abs.chr : value.first)
        end
      end
    end

    context 'with an existing record' do
      after do
        options.fetch(:update_values).each do |key, value|
          expect(
            bytefield_model.send(key)
          ).to eq(value.is_a?(Fixnum) ? value.abs.chr : value.first)
        end
      end

      context 'on update' do
        it 'sets expected values' do
          bytefield_model.update(options.fetch(:update_values))
        end
      end

      context 'on set and save' do
        it 'saves expected values' do
          options.fetch(:update_values).each do |key, value|
            bytefield_model.send("#{key}=", value)
          end
          bytefield_model.save
        end
      end

      context 'on update_attributes' do
        it 'saves expected values' do
          bytefield_model.update_attributes(options.fetch(:update_values))
        end
      end
    end
  end

  context 'with single-byte values' do
    include_examples(
      'with these values',
      original_values: { a: 'ß', b: 'å', c: '3' },
      update_values: { a: "\xFF", b: '2', c: "\xDD" }
    )
  end

  context 'with multi-byte values' do
    include_examples(
      'with these values',
      original_values: { a: 'ßeta', b: 'ålpha', c: '3;3' },
      update_values: { a: '≈123', b: '233', c: 'asdf' }
    )
  end

  context 'with positive integer values' do
    include_examples(
      'with these values',
      original_values: { a: 0, b: 11, c: 12 },
      update_values: { a: 25, b: 127, c: 65 }
    )
  end

  context 'with negative integer values' do
    include_examples(
      'with these values',
      original_values: { a: -1, b: -11, c: -12 },
      update_values: { a: -25, b: -127, c: -65 }
    )
  end

  context 'when updating the original raw column' do
    let(:bytefield_model) do
      BytefieldModel.create(a: 'X', b: 'Y', c: 'Z')
    end

    context 'with a value longer than the bytefield' do
      before do
        bytefield_model.update_attributes(my_bytefield: "AB\xFFxxx")
      end

      it 'sets individual fields' do
        expect(bytefield_model.a).to eq('A')
        expect(bytefield_model.b).to eq('B')
        expect(bytefield_model.c).to eq("\xFF")
      end

      it 'allows overflow of the bytefield' do
        expect(bytefield_model.my_bytefield.length).to eq(6)
      end
    end

    context 'with a value shorter than the bytefield' do
      before do
        bytefield_model.update_attributes(my_bytefield: 'x')
      end

      it 'sets the overlapping value as expected' do
        expect(bytefield_model.a).to eq('x')
      end

      it 'returns the remaining fields as nil' do
        expect(bytefield_model.b).to be_nil
        expect(bytefield_model.c).to be_nil
      end
    end
  end
end
