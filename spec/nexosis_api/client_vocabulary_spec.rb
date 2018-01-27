require 'helper'

describe NexosisApi::Client::Vocabulary do
  describe '#list_vocabularies', vcr: { cassette_name: 'list_vocabularies' } do
    context 'given an existing vocabulary' do
      it 'returns existing in list' do
        vocabs = test_client.list_vocabularies
        expect(vocabs).to be_a(NexosisApi::PagedArray)
        expect(vocabs.item_total).to be > 0
      end
    end
  end
end
