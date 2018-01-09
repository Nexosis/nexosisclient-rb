require 'helper'
require 'csv'
require 'json'

describe NexosisApi::Client::Models do

  attr_accessor :model_id

  describe '#list_models', :vcr => { :cassette_name => 'list_models' } do
    context 'given some existing models' do
      it 'returns a list of model summaries' do
        actual = test_client.list_models
        expect(actual).to_not be_nil
        expect(actual).to_not be_empty
      end
    end
  end

  describe '#get_model', :vcr => { :cassette_name => 'get_a_model' } do
    context 'given an existing model' do
      it 'returns a model summary' do
        session = test_client.create_model('TestRuby_NTS', 'target')
        if (@model_id.nil?)
          loop do
            status_check = test_client.get_session session.session_id
            @model_id = status_check.model_id
            break if (status_check.status == 'completed' || status_check.status == 'failed')
            sleep 5
          end
        end
        actual = test_client.get_model(@model_id)
        expect(actual).to_not be_nil
        expect(actual.datasource_name).to eql('TestRuby_NTS')
      end
    end
  end

  describe '#remove_model' do
    context 'without model_id' do
      it 'raises argument error' do
        expect{ test_client.remove_model('') }.to raise_error{ |error|
          expect(error).to be_a(ArgumentError)
        }
      end
    end
  end

  describe '#remove_model', :vcr => { :cassette_name => 'remove_existing_model' } do
    context 'given a model id' do
      it 'removes the model' do
        # create a model to remove
        session = test_client.create_model('TestRuby_NTS', 'target')
        model_id = session.model_id
        loop do
          status_check = test_client.get_session session.session_id
          model_id = status_check.model_id
          break if (status_check.status == 'completed' || status_check.status == 'failed')
          sleep 5
        end
        test_client.remove_model(model_id)
        expect{test_client.get_model(model_id)}.to raise_error{ |error|
          expect(error).to be_a(NexosisApi::HttpException)
          expect(error.code).to eql(404)
        }
      end
    end
  end

  describe '#remove_models' do
    context 'given no parameters' do
      it 'raises argument error' do
        expect { test_client.remove_models }.to raise_error { |error|
          expect(error).to be_a(ArgumentError)
        }
      end
    end
  end

  describe '#remove_models', :vcr => { :cassette_name => 'remove_datasource_models' } do
    context 'given arguments' do
      it 'creates a query string' do
        test_client.remove_models 'TestDataSource', '2017-01-01', '2017-01-10'
      end
    end
  end

  describe '#predict' do
    context 'given no model id' do
      it 'raises argument error' do
        expect { test_client.predict }.to raise_error { |error|
        expect(error).to be_a(ArgumentError)
      }
      end
    end
  end

  describe '#predict', :vcr => { :cassette_name => 'predict_from_model' } do
    context 'given a trained model and features' do
      it 'predicts values' do
        if (@model_id.nil?)
          session = test_client.create_model('TestRuby_NTS', 'target')
          loop do
            status_check = test_client.get_session session.session_id
            @model_id = status_check.model_id
            break if (status_check.status == 'completed' || status_check.status == 'failed')
            sleep 5
          end
        end
        data = JSON.parse('[{"feature": "15"}]')
        actual = test_client.predict @model_id, data
        expect(actual).to_not be_nil
        expect(actual.predictions[0]['target'].to_f).to be > 0
      end
    end
  end

  describe '#predict', vcr: { cassette_name: 'predict_with_scores' } do
    context 'given a classification model and flag' do
      it 'returns scores for each class' do
        available = test_client.list_models('iris')
        completed = available.first unless available.empty?
        completed = create_class_test_model if completed.nil?
        actual = test_client.predict(completed.model_id,
                                     { petal_len:	3.6, sepal_len: 5.6, petal_width: 1.3, sepal_width: 2.9 },
                                     includeClassScores: true)
        expect(actual).to be_a(NexosisApi::PredictResponse)
        expect(actual.predictions.first['iris:versicolor'].to_i).to eql(1)
      end
    end
  end

  private

  def create_class_test_model
    data = CSV.open('spec/fixtures/iris_data.csv', 'rb', headers: true)
    test_client.create_dataset_csv('Iris', data)
    completed = test_client.create_model('Iris', 'iris', {}, 'classification')
    loop do
      status_check = test_client.get_session completed.session_id
      break if (status_check.status == 'completed' || status_check.status == 'failed')
      sleep 5
    end
    completed
  end
end
