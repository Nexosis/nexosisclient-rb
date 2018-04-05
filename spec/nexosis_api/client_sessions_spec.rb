require 'helper'
require 'csv'

describe NexosisApi::Client::Sessions do
  describe '#create_forecast_session', :vcr => {:cassette_name => 'create_forecast_dataset'} do
    context 'given an existing dataset name' do
      it 'returns a started session' do
        actual = test_client.create_forecast_session('TestRuby', '2014-05-20', '2014-05-21', 'sales')
        expect(actual).to be_instance_of(NexosisApi::SessionResponse)
        expect(actual.type).to eql('forecast')
      end
    end
  end

  describe '#create_impact_session', :vcr  => {:cassette_name => 'create_impact_session'} do
    context 'given an existing dataset name' do
      it 'returns a started session' do
        actual = test_client.create_impact_session('TestRuby', '05-01-2014', '05-10-2014', 'test event', 'sales')
        expect(actual).to be_instance_of(NexosisApi::SessionResponse)
        expect(actual.type).to eql('impact')
      end
    end
  end

  describe '#create_impact_session', :vcr  => {:cassette_name => 'create_impact_session_fail'} do
    context 'given an end date outside the dataset dates' do
      it 'throws exception' do
        expect{ test_client.create_impact_session('TestRuby', '01-22-2017', '02-22-2017', 'test event', 'sales') }.to raise_error { |error|
          expect(error).to be_a(NexosisApi::HttpException)
        }
      end
    end
  end

  describe '#get_session_result_data', :vcr  => {:cassette_name => 'get_session_results'} do
    context 'given the id of an completed session' do
      it 'returns the results of the session analysis' do
        available = test_client.list_sessions({}, 0, 20)
        completed = available.select { |s| s.status == 'completed' && s.prediction_domain == 'forecast' }.first
        completed = test_client.create_forecast_session('TestRuby', '2014-05-20', '2014-05-25', 'sales') if completed.nil?
        loop do
          status_check = test_client.get_session completed.session_id
          break if (status_check.status == 'completed' || status_check.status == 'failed')
          puts 'waiting in get_session_results'
          sleep 5
        end
        actual = test_client.get_session_result_data completed.session_id
        expect(actual).to be_a(NexosisApi::SessionResult)
        expect(actual.data).not_to be_empty
        expect(actual.status_history).to be_a(Array)
      end
    end
  end
  
  describe 'list_sessions', :vcr  => {:cassette_name => 'list_sessions_dataset'} do
    context 'given a request with a dataset name' do
      it 'returns an array of all sessions with that dataset' do
        actual = test_client.list_sessions :dataset_name=>'TestRuby'
        expect(actual).to be_a(Array)
        actual_map = actual.map { |s| s.datasource_name }
        expect(actual_map).to all( be_a(String).and include('TestRuby') )
      end
    end
  end

  describe '#list_sessions', :vcr  => {:cassette_name => 'list_sessions_eventname'} do
    context 'given a request with an event name' do
      it 'returns an array of all sessions with that event' do
        actual = test_client.list_sessions :event_name=>'test event'
        expect(actual).to be_a(Array)
        actual_map = actual.map { |s| s.extra_parameters['event'] }
        expect(actual_map).to all( be_a(String).and include('test') )
      end
    end
  end

  describe '#list_sessions', :vcr  => {:cassette_name => 'list_sessions_dates'} do
    context 'given a request with a start and end date' do
      it 'returns an array of all sessions within that time frame' do
        start_date = DateTime.strptime('6-14-2017', '%m-%d-%Y')
        end_date = DateTime.strptime('6-30-2017', '%m-%d-%Y')
        actual = test_client.list_sessions :requested_after_date => start_date, :requested_before_date => end_date
        expect(actual).to be_a(Array)
        actual.each do |sr|
          requested_date = DateTime.parse(sr.statusHistory.select {|v| v.has_value? 'requested'}[0]['date'])
          expect(requested_date).to be_between(start_date,end_date).inclusive
        end
      end
    end
  end

  describe '#remove_sessions', :vcr  => {:cassette_name => 'remove_sessions'} do
    context 'given a dataset name' do
      it 'removes any session created with that name' do
        # create the session to remove
        existing_dataset = 'ToRemoveRuby'
        json = {
          'columns' => {
            'timestamp' =>
            {
              'dataType' => 'date',
              'role' => 'timestamp'
            },
            'sales' =>
            {
              'dataType' => 'numeric',
              'role' => 'target'
            }
          },
          'data' => [
            {
              'timestamp' => '2017-01-01T00:00:00+00:00',
              'sales' => '2948.74'
            },
            {
              'timestamp' => '2017-01-02T00:00:00+00:00',
              'sales' => '1906.35'
            },
            {
              'timestamp' => '2017-01-03T00:00:00+00:00',
              'sales' => '4523.42'
            },
            {
              'timestamp' => '2017-01-04T00:00:00+00:00',
              'sales' => '4586.85'
            },
            {
              'timestamp' => '2017-01-05T00:00:00+00:00',
              'sales' => '4538.04'
            },
            {
              'timestamp' => '2017-01-06T00:00:00+00:00',
              'sales' => '4538.04'
            },
            {
              'timestamp' => '2017-01-07T00:00:00+00:00',
              'sales' => '4538.04'
            },
            {
              'timestamp' => '2017-01-08T00:00:00+00:00',
              'sales' => '4538.04'
            },
            {
              'timestamp' => '2017-01-09T00:00:00+00:00',
              'sales' => '4538.04'
            },
            {
              'timestamp' => '2017-01-10T00:00:00+00:00',
              'sales' => '4538.04'
            },
            {
              'timestamp' => '2017-01-11T00:00:00+00:00',
              'sales' => '4538.04'
            },
            {
              'timestamp' => '2017-01-12T00:00:00+00:00',
              'sales' => '4538.04'
            },
            {
              'timestamp' => '2017-01-13T00:00:00+00:00',
              'sales' => '4538.04'
            },
            {
              'timestamp' => '2017-01-14T00:00:00+00:00',
              'sales' => '4538.04'
            },
            {
              'timestamp' => '2017-01-15T00:00:00+00:00',
              'sales' => '4538.04'
            }
          ]
        }
        test_client.create_dataset_json(existing_dataset, json)
        new_session = test_client.create_forecast_session(existing_dataset, '2017-01-16', '2017-01-17', 'sales')
        test_client.remove_sessions :dataset_name => existing_dataset
        expect{ test_client.get_session(new_session.session_id) }.to raise_error{ |error|
          expect(error).to be_a(NexosisApi::HttpException)
          expect(error.code).to eql(404)
        }
        test_client.remove_dataset existing_dataset
      end
    end
  end

  describe '#create_forecast_session_data', :vcr => {:cassette_name => 'create_forecast_session_features'} do
    context 'given a metadata specification' do
      it 'executes a session with a feature identified' do
        columns = []
        columns << NexosisApi::Column.new('transactions',{ 'dataType' => NexosisApi::ColumnType::NUMERIC, 'role' => NexosisApi::ColumnRole::FEATURE })
        actual  = test_client.create_forecast_session('TestRuby', '2014-04-08', '2014-05-08', 'sales', 'day', columns)
        expect(actual).to be_a(NexosisApi::SessionResponse)
        expect(actual.target_column).to eql('sales')
        expect(actual.column_metadata[2].role).to eql(NexosisApi::ColumnRole::FEATURE)
      end
    end
  end

  describe '#create_forecast_session', :vcr => {:cassette_name => 'create_session_no_dataset_404'} do
    context 'given a dataset name that does not exist' do
      it 'fails with a 404 http message' do
        expect{test_client.create_forecast_session('IDontExist', '01-22-2013', '02-22-2013', 'sales')}.to raise_error{ |error|
          expect(error).to be_a(NexosisApi::HttpException)
          expect(error.code).to eql(404)
        }
      end
    end
  end

  describe '#create_forecast_session', :vcr => {:cassette_name => 'create_session_invalid_interval'} do
    context 'given a request with invalid interval specified' do
      it 'fails with a 400 message' do
         expect{test_client.create_forecast_session('TestRuby', '01-22-2013', '02-22-2013', 'sales', 'seconds')}.to raise_error{ |error|
          expect(error).to be_a(NexosisApi::HttpException)
          expect(error.code).to eql(400)
          expect(error.message).to include("The value 'seconds' is not valid")
         }
      end
    end
  end

  describe '#list_sessions',:vcr => {:cassette_name => 'list_sessions_pagesize'} do
    context 'given a page size' do
      it 'should return lte that size' do
        actual = test_client.list_sessions({}, 0, 3)
        expect(actual).to be_a(Array)
        expect(actual.size).to eql(3)
      end
    end
  end

  describe '#list_sessions',:vcr => {:cassette_name => 'list_sessions_paged'} do
    context 'given a page number' do
      it 'should return next result set' do
        both = test_client.list_sessions({}, 0, 2)
        id1 = both[0].session_id
        id2 = both[1].session_id
        page_one = test_client.list_sessions({},0,1)
        expect(page_one[0].session_id).to eql(id1)
        page_two = test_client.list_sessions({},1,1)
        expect(page_two[0].session_id).to eql(id2)
      end
    end
  end

  describe '#create_forecast_session', :vcr => {:cassette_name => 'create_forecast_session_numericmeasure'} do
    context 'given a metadata specification with measure' do
      it 'executes a session with measure datatype' do
        columns = []
        columns << NexosisApi::Column.new('transactions',{ 'dataType' => NexosisApi::ColumnType::NUMERICMEASURE, 'role' => NexosisApi::ColumnRole::FEATURE })
        actual  = test_client.create_forecast_session('TestRuby', '2013-07-18', '2013-08-28', 'sales', 'day', columns)
        expect(actual).to be_a(NexosisApi::SessionResponse)
        expect(actual.column_metadata[2].type).to eql(NexosisApi::ColumnType::NUMERICMEASURE)
        expect(actual.column_metadata[2].imputation).to eql('mean')
        expect(actual.column_metadata[2].aggregation).to eql('mean')
      end
    end
  end

  describe '#create_model', :vcr => {:cassette_name => 'create_model_session'} do
    context 'given a non-timeseries datasource' do
      it 'starts a session to create a model' do
        actual = test_client.create_model('TestRuby_NTS', 'profit')
        expect(actual).to be_a(NexosisApi::SessionResponse)
      end
    end
  end

  describe '#get_session', :vcr => {:cassette_name => 'session_predict_interval'} do
    context 'given a completed session' do
      it 'returns the available intervals' do
        available = test_client.list_sessions
        actual = available.select { |s| s.status == 'completed' && s.type == 'forecast' }.first
        expect(actual.prediction_intervals).to be_a(Array)
        expect(actual.prediction_intervals).to_not be_empty
      end
    end
  end

  describe '#get_session_result_data', vcr: { cassette_name: 'session_get_prediction_interval' } do
    context 'given an available prediction interval' do
      it 'sets the query parameter' do
        available = test_client.list_sessions({}, 0, 10)
        completed = available.select { |s| s.status == 'completed' && s.type == 'forecast' }.first
        unless (completed.nil?)
          actual = test_client.get_session_result_data completed.session_id, 0, 50, { prediction_interval: '.5' }
          expect(actual).to_not be_nil
        end
      end
    end
  end

  describe '#get_confusion_matrix', vcr: { cassette_name: 'session_get_confusion_matrix' } do
    context 'given a classification result' do
      it 'returns confusion matrix' do
        available = test_client.list_sessions({}, 0, 10)
        completed = available.select { |s| s.status == 'completed' && s.prediction_domain == 'classification' }.first
        completed = create_class_test_model if completed.nil?
        actual = test_client.get_confusion_matrix(completed.session_id)
        expect(actual).to_not be_nil
        expect(actual.confusion_matrix).to be_a(Array)
        expect(actual.classes).to be_a(Array)
      end
    end
  end

  describe '#create_classification_model', vcr: { cassette_name: 'session_unbalanced' } do
    context 'given a request for unbalanced' do
      it 'the request adds param' do
        actual = test_client.create_classification_model('TestRuby_NTS', 'profit', {}, false)
        expect(actual.extra_parameters['balance']).to be(false)
      end
    end
  end

  describe '#create_anomalies_model', vcr: { cassette_name: 'model_anomalies' } do
    context 'given an anomaly data source' do
      it 'starts an anomalies session' do
        actual = test_client.create_anomalies_model('TestRuby_NTS')
        expect(actual.prediction_domain).to eql('anomalies')
      end
    end
  end

  describe '#get_anomaly_scores', vcr: { cassette_name: 'anomaly_scores' } do
    context 'given a completed anomalies session' do
      it 'pulls back scores from session' do
        available = test_client.list_sessions({}, 0, 20)
        completed = available.select { |s| s.status == 'completed' && s.prediction_domain == 'anomalies' }.first
        if (completed.nil?)
          completed = test_client.create_anomalies_model('TestRuby_NTS', {}, true)
          loop do
            status_check = test_client.get_session completed.session_id
            break if (status_check.status == 'completed' || status_check.status == 'failed')
            puts 'waiting in anomaly_scores'
            sleep 5
          end
        end
        actual = test_client.get_anomaly_scores(completed.session_id)
        expect(actual).to be_a(NexosisApi::AnomalyScores)
        expect(actual.percent_anomalies).to be_within(0.09).of(0.1)
        expect(actual.data.length).to be <= 50
      end
    end
  end

  describe '#get_classification_scores', vcr: { cassette_name: 'class_scores' } do
    context 'given a finished classification session' do
      it 'returns classification scores' do
        available = test_client.list_sessions({}, 0, 20)
        completed = available.select { |s| s.status == 'completed' && s.prediction_domain == 'classification' }.first
        completed = create_class_test_model if completed.nil?
        actual = test_client.get_class_scores(completed.session_id)
        expect(actual).to be_a(NexosisApi::ClassifierScores)
        expect(actual.classes).to_not be_empty
        expect(actual.metrics).to_not be_empty
      end
    end
  end

  describe '#get_feature_importance', vcr: { cassette_name: 'feature_importance' } do
    context 'given a finished session' do
      it 'returns feature importance scores' do
        available = test_client.list_sessions({}, 0, 20)
        completed = available.select { |s| s.status == 'completed' && s.supports_feature_importance == true }.first
        completed = create_class_test_model if completed.nil?
        actual = test_client.get_feature_importance(completed.session_id)
        expect(actual).to be_a(NexosisApi::FeatureImportance)
        expect(actual.scores).to_not be_empty
      end
    end
  end

  describe '#get_distance_metrics', vcr: { cassette_name: 'anomaly_distances' } do
    context 'given a finished session' do
      it 'returns feature importance scores' do
        available = test_client.list_sessions({}, 0, 20)
        completed = available.select { |s| s.status == 'completed' && s.prediction_domain == 'anomalies' }.first
        completed = create_anomaly_test_model if completed.nil?
        actual = test_client.get_distance_metrics(completed.session_id)
        expect(actual).to be_a(NexosisApi::AnomalyDistances)
        expect(actual.data).to_not be_empty
        expect((actual.data.map &:distance).length).to be > 10
      end
    end
  end

  describe '#get_timeseries_outliers', vcr: { cassette_name: 'timeseries_outliers' } do
    context 'given a finished session' do
      it 'returns feature importance scores' do
        available = test_client.list_sessions({}, 0, 20)
        completed = available.select { |s| s.status == 'completed' && s.prediction_domain == 'forecast' }.first
        unless completed.nil?
          actual = test_client.get_timeseries_outliers(completed.session_id)
          expect(actual).to be_a(NexosisApi::TimeseriesOutliers)
          expect(actual.data).to_not be_empty
          expect((actual.data.map &:actual).length).to be > 0
        end
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
      puts 'waiting in create_class_test_model'
      sleep 5
    end
    completed
  end

  def create_anomaly_test_model
    data = CSV.open('spec/fixtures/cardio.csv', 'rb', headers: true)
    test_client.create_dataset_csv('Cardio_Test', data)
    completed = test_client.create_anomalies_model('Cardio_Test')
    loop do
      status_check = test_client.get_session completed.session_id
      break if (status_check.status == 'completed' || status_check.status == 'failed')
      puts 'waiting in create_anomaly_test_model'
      sleep 10
    end
    completed
  end
end
