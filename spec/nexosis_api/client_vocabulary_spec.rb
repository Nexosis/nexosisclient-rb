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

  describe '#get_vocabulary', vcr: { cassette_name: 'get_vocab_words' } do
    context 'given an existing vocabulary id' do
      it 'returns list of words' do
        existing = test_client.list_vocabularies
        vocab = existing.first unless existing.empty?
        vocab = create_vocab if vocab.nil?
        words = test_client.get_vocabulary(vocab.vocabulary_id)
        expect(words).to be_a(NexosisApi::PagedArray)
        expect(words.item_total).to be > 0
        expect(words[0].text).to_not be_nil
      end
    end
  end

  private

  # @private
  def create_vocab
    data = CSV.open('spec/fixtures/textdata.csv', 'rb', headers: true)
    test_client.create_dataset_csv('TestRuby_Text', data)
    session = test_client.create_classification_model('TestRuby_Text', 'sentiment')
    loop do
      status_check = test_client.get_session session.session_id
      break if (status_check.status == 'completed' || status_check.status == 'failed')
      puts 'waiting in create_vocab'
      sleep 10
    end
    test_client.list_vocabularies.first
  end
end
