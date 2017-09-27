require 'helper'
require 'csv'
require 'json'

describe NexosisApi::Client::Models do
  before(:all) do
    # prepare at least one model for use
    test_client.create_model('TestRuby_NTS', 'SalePrice')
  end

  describe '#list_models' do
    context 'given some existing models' do
      it 'returns a list of model summaries' do
        actual = test_client.list_models
        expect(actual).to_not be_nil
        expect(actual).to_not be_empty
      end
    end
  end
end
