require 'helper'
require 'csv'
require 'json'

describe NexosisApi::Client::Models do
  before(:all) do
    # prepare at least one model for use
    session = test_client.create_model('TestRuby_NTS', 'SalePrice')
    loop do
      status_check = test_client.get_session session.sessionId
      break if (status_check.status == 'completed' || status_check.status == 'failed')
      sleep 10
    end
    @model_id = session.model_id
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

  describe '#get_model' do
    context 'given an existing model' do
      it 'returns a model summary' do
        actual = test_client.get_model(@model_id)
        expect(actual).to_not be_nil
      end
    end
  end
end
