require 'helper'

describe NexosisApi::Session do
  describe '#initialize' do
    context 'given a hash with session values' do
      it 'creates an instance with those values' do
        target = NexosisApi::Session.new({'sessionId':'015ca6f7-ca42-49de-9601-f5493a03cbfa','type':'forecast','status':'completed','requestedDate':'2017-06-14T14:17:56.012548+00:00','statusHistory':[{'date':'2017-06-14T14:17:56.012548+00:00','status':'requested'},{'date':'2017-06-14T14:17:57.0034498+00:00','status':'started'},{'date':'2017-06-14T14:18:05.1763039+00:00','status':'completed'}],'extraParameters':{},'columns':{},'dataSetName':'RubyTest','targetColumn':'sales','startDate':'2017-01-22T00:00:00+00:00','endDate':'2017-02-22T00:00:00+00:00','callbackUrl':nil,'isEstimate':false,'resultInterval':nil})
        expect(target).to_not be_nil
        expect(target.dataSetName).to eql('RubyTest')
      end
    end
  end
end


describe NexosisApi::SessionResponse do
  describe '#initialize' do
    context 'given a hash with session response values' do
      it 'creates an instance with those values' do
        target = NexosisApi::SessionResponse.new({'nexosis-account-balance'=>['6548.25'],'nexosis-request-cost'=>['15.00'], 'session' => {'sessionId':'015ca6f7-ca42-49de-9601-f5493a03cbfa','type':'forecast','status':'completed','requestedDate':'2017-06-14T14:17:56.012548+00:00','statusHistory':[{'date'=>'2017-06-14T14:17:56.012548+00:00','status'=>'requested'},{'date'=>'2017-06-14T14:17:57.0034498+00:00','status'=>'started'},{'date'=>'2017-06-14T14:18:05.1763039+00:00','status'=>'completed'}],'extraParameters':{},'columns':{},'dataSetName':'RubyTest','targetColumn':'sales','startDate':'2017-01-22T00:00:00+00:00','endDate':'2017-02-22T00:00:00+00:00','callbackUrl':nil,'isEstimate':false,'resultInterval':nil}})
        expect(target).to_not be_nil
        expect(target.dataSetName).to eql('RubyTest')
        expect(target.cost).to eql('15.00')
      end
    end
  end
end

describe NexosisApi::SessionResult do
  describe '#initialize' do
    context 'given a hash with session result values' do
      it 'creates an instance with those values' do
        target = NexosisApi::SessionResult.new({'metrics'=>{},'data'=>[{'timestamp'=>'2017-01-03T00:00:00.0000000Z','foo'=>'533.87'}],'sessionId':'015cf057-8f1c-422b-9c1d-3f5423362fd5','type':'forecast','status':'started','requestedDate':'2017-06-28T20:14:49.115896+00:00','statusHistory':[{'date'=>'2017-06-28T20:14:49.115896+00:00','status'=>'requested'},{'date'=>'2017-06-28T20:14:50.5442656+00:00','status'=>'started'}],'extraParameters':{},'columns'=>{'foo'=>{'dataType'=>'numeric','role'=>'target'},'timestamp'=>{'dataType'=>'date','role'=>'timestamp'}},'dataSetName':'forecast.015cf057-8f1c-422b-9c1d-3f5423362fd5','targetColumn':'foo','startDate':'2017-01-03T00:00:00+00:00','endDate':'2017-01-04T00:00:00+00:00','callbackUrl':nil,'isEstimate':false,'resultInterval':'day','links':[{'rel':'results','href':'https://api.uat.nexosisdev.com/v1/sessions/015cf057-8f1c-422b-9c1d-3f5423362fd5/results'},{'rel':'data','href':'https://api.uat.nexosisdev.com/v1/data/forecast.015cf057-8f1c-422b-9c1d-3f5423362fd5'}]})
        expect(target).to_not be_nil
        expect(target.column_metadata).to_not be_nil
      end
    end
  end
end

describe NexosisApi::Join do
  describe '#initialize' do
    context 'given a hash of join with calendar' do
      it 'creates an instance that has calendar join target' do
        target = NexosisApi::Join.new({'calendar' => {'name' => 'Nexosis.Holidays'}})
        expect(target.join_target).to_not be_nil
        expect(target.join_target.name).to eql('Nexosis.Holidays')
      end
    end
  end

  describe '#initialize' do
    context 'given a hash of join with dataset' do
      it 'creates an instance that has dataset join target' do
        target = NexosisApi::Join.new({'dataSet' => {'name' => 'TestDataset'}})
        expect(target.join_target).to_not be_nil
        expect(target.join_target.dataset_name).to eql('TestDataset')
      end
    end
  end

  describe '#initialize' do
    context 'given a hash with a column alias' do
      it 'creates an instance with column options' do
        target = NexosisApi::Join.new({'dataSet' => {'name' => 'TestDataset'}, 'columnOptions' => { 'some_column' => { 'alias' => 'column_alias' } } })
        expect(target.column_options).to_not be_nil
        expect(target.column_options[0].alias).to eql('column_alias')
        expect(target.column_options[0].column_name).to eql('some_column')
      end
    end
  end

  describe '#to_hash' do
    context 'given a join object' do
      it 'provides hash matching api json' do
        target = NexosisApi::Join.new({'dataSet' => {'name' => 'TestDataset'}, 'columnOptions' => { 'some_column' => { 'alias' => 'column_alias' }, 'other_column' => { 'alias' => 'another_alias' } } })
        actual = target.to_hash
        expect(actual.to_json).to eql('{"dataSet":{"name":"TestDataset"},"columnOptions":{"some_column":{"alias":"column_alias"},"other_column":{"alias":"another_alias"}}}')
      end
    end
  end
end

describe NexosisApi::ModelSummary do
  describe '#initialize' do
    context 'given a hash of values' do
      it 'creates new object initialized with values' do
        values = {
          'modelId': '9e80119b-9dbd-4da9-b576-22ef3e81bb42',
          'dataSourceName': 'test_ds',
          'predictionDomain': 'regression',
          'createdDate': '2017-09-26',
          'algorithm': {
            'name': 'test',
            'description': 'for testing',
            'key': 'smoke_test'
          },
          'columns': {
            'first_column': {
              'dataType' => 'numeric',
              'role' => 'key'
            }
          },
          'metrics': {
            'rmse': 6.3245,
            'lambda': 0.00215
          }
        }
        target = NexosisApi::ModelSummary.new(values)
        expect(target.data_source_name).to eql('test_ds')
        expect(target.algorithm.name).to eql('test')
        expect(target.column_metadata[0].type).to eql(NexosisApi::ColumnType::NUMERIC)
      end
    end
  end

  describe NexosisApi::DatasetSummary do
    describe '#timeseries?' do
      context 'given a dataset with a timestamp column' do
        it 'returns true' do
          dataset = NexosisApi::DatasetSummary.new(
            {
              'dataSetName' => 'testtimestamp',
              'columns' => {
                'timestamp' => {
                  'type' => NexosisApi::ColumnType::DATE,
                  'role' => NexosisApi::ColumnRole::TIMESTAMP
                },
                'nottimestamp' => {
                  'type' => NexosisApi::ColumnType::NUMERIC
                }
              }
            }
          )
          expect(dataset.timeseries?).to be true
        end
      end
    end
  end
end
