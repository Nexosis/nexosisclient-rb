require 'helper'

describe NexosisApi::Session do
  describe '#initialize' do
    context 'given a hash with session values' do
      it 'creates an instance with those values' do
        target = NexosisApi::Session.new(session_hash)
        expect(target).to_not be_nil
        expect(target.datasource_name).to eql('RubyTest')
      end
    end
  end

  describe '#initialize' do
    context 'given a hash of messages' do
      it 'fills the messages array' do
        target = NexosisApi::Session.new({'messages' => [{'severity': 'warning', 'message': 'this is a test'}]})
        expect(target.messages).to_not be_nil
        expect(target.messages[0].severity).to eql('warning')
        expect(target.messages[0].message).to eql('this is a test')
      end
    end
  end
end

describe NexosisApi::SessionResponse do
  describe '#initialize' do
    context 'given a hash with session response values' do
      it 'creates an instance with those values' do
        target = NexosisApi::SessionResponse.new({'Nexosis-Account-DataSetCount-Allotted'=>'60','Nexosis-Account-PredictionCount-Current'=>'11', 'session' => {'sessionId':'015ca6f7-ca42-49de-9601-f5493a03cbfa','type':'forecast','status':'completed','requestedDate':'2017-06-14T14:17:56.012548+00:00','statusHistory':[{'date'=>'2017-06-14T14:17:56.012548+00:00','status'=>'requested'},{'date'=>'2017-06-14T14:17:57.0034498+00:00','status'=>'started'},{'date'=>'2017-06-14T14:18:05.1763039+00:00','status'=>'completed'}],'extraParameters':{},'columns':{},'dataSourceName':'RubyTest','targetColumn':'sales','startDate':'2017-01-22T00:00:00+00:00','endDate':'2017-02-22T00:00:00+00:00','callbackUrl':nil,'resultInterval':nil}})
        expect(target).to_not be_nil
        expect(target.datasource_name).to eql('RubyTest')
        expect(target.datasets_allotted).to eql('60')
        expect(target.predictions_current).to eql('11')
      end
    end
  end
end

describe NexosisApi::SessionResult do
  describe '#initialize' do
    context 'given a hash with session result values' do
      it 'creates an instance with those values' do
        target = NexosisApi::SessionResult.new({'metrics'=>{},'data'=>[{'timestamp'=>'2017-01-03T00:00:00.0000000Z','foo'=>'533.87'}],'sessionId':'015cf057-8f1c-422b-9c1d-3f5423362fd5','type':'forecast','status':'started','requestedDate':'2017-06-28T20:14:49.115896+00:00','statusHistory':[{'date'=>'2017-06-28T20:14:49.115896+00:00','status'=>'requested'},{'date'=>'2017-06-28T20:14:50.5442656+00:00','status'=>'started'}],'extraParameters':{},'columns'=>{'foo'=>{'dataType'=>'numeric','role'=>'target'},'timestamp'=>{'dataType'=>'date','role'=>'timestamp'}},'dataSetName':'forecast.015cf057-8f1c-422b-9c1d-3f5423362fd5','targetColumn':'foo','startDate':'2017-01-03T00:00:00+00:00','endDate':'2017-01-04T00:00:00+00:00','callbackUrl':nil, 'resultInterval':'day','links':[{'rel':'results','href':'https://api.uat.nexosisdev.com/v1/sessions/015cf057-8f1c-422b-9c1d-3f5423362fd5/results'},{'rel':'data','href':'https://api.uat.nexosisdev.com/v1/data/forecast.015cf057-8f1c-422b-9c1d-3f5423362fd5'}]})
        expect(target).to_not be_nil
        expect(target.column_metadata).to_not be_nil
      end
    end
  end

  describe '#initialize' do
    context 'given a hash with metrics' do
      it 'fills out metrics as hash' do
        session_hash = { 'metrics': {
          'meanAbsoluteError': '15990.948459514153',
          'meanAbsolutePercentError': '0.092227013821557124',
          'rootMeanSquareError': '29872.102288912662'
        }, 'data': [] }
        target = NexosisApi::SessionResult.new(session_hash)
        expect(target.metrics).to_not be_nil
        expect(target.metrics[0].name).to eql('meanAbsoluteError')
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
        expect(target.datasource_name).to eql('test_ds')
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

describe NexosisApi::PagedArray do
  describe '#initialize' do
    context 'given a list response hash' do
      it 'fills the array and props' do
        test_arr = [1, 2, 3]
        response_hash = { items: [],
                          pageNumber: 1,
                          totalPages: 2,
                          pageSize: 10,
                          totalCount: 20,
                          'links' => [{ rel: 'self', href: 'http://example.com' }] }
        actual = NexosisApi::PagedArray.new(response_hash, test_arr)
        expect(actual).to be_a(Array)
        expect(actual.length).to eql(3)
        expect(actual.page_number).to eql(1)
        expect(actual.total_pages).to eql(2)
        expect(actual.page_size).to eql(10)
        expect(actual.item_total).to eql(20)
        expect(actual.links[0]).to be_a(NexosisApi::Link)
      end
    end
  end

  describe NexosisApi::ClassifierResult do
    describe '#initialize' do
      context 'given a confusion matrix result' do
        it 'parses matrix and other session data' do
          actual = NexosisApi::ClassifierResult.new({ 'sessionId' => '0000000000', 'classes':['label1', 'label2'], 'confusionMatrix':[[5, 0],[0, 5]] })
          expect(actual.session_id).to eql('0000000000')
          expect(actual.confusion_matrix).to_not be_nil
          expect(actual.classes).to_not be_nil
          expect(actual.confusion_matrix[0][1]).to eql(0)
          expect(actual.classes[0]).to eql('label1')
        end
      end
    end
  end
end

describe NexosisApi::Algorithm do
  describe '#initialize' do
    context 'given an algorithm hash' do
      it 'creates new object initialized with values' do
        algo_hash = { 'name': 'SVC Sigmoid',
                      'description': 'Support Vector Classification using Sigmoid kernel',
                      'key': 'svc_sigmoid' }
        target = NexosisApi::Algorithm.new(algo_hash)
        expect(target).to_not be_nil
        expect(target.key).to eql('svc_sigmoid')
        expect(target.description).to eql('Support Vector Classification using Sigmoid kernel')
        expect(target.name).to eql('SVC Sigmoid')
      end
    end
  end
end

describe NexosisApi::AlgorithmContestant do
  describe '#initialize' do
    context 'given a contestant hash' do
      it 'creates new object initialized with values' do
        target = NexosisApi::AlgorithmContestant.new(contestant_hash)
        expect(target.id).to eql('01604c19-60a6-4dbc-a8b6-68fadbe180d4')
        expect(target).to_not be_nil
        expect(target.metrics.length).to be(5)
        expect(target.datasource_properties.length).to be(2)
      end
    end
  end
end

describe NexosisApi::SessionContest do
  describe '#initialize' do
    context 'given a contest hash' do
      it 'creates new object initialized with values' do
        contest_hash = session_hash
        contest_hash['championMetric'] = 'macroAverageF1Score'
        contest_hash['champion'] = contestant_hash
        contest_hash['contestants'] = contestant_array
        target = NexosisApi::SessionContest.new(contest_hash)
        expect(target).to_not be_nil
        expect(target.session_id).to eql('015ca6f7-ca42-49de-9601-f5493a03cbfa')
        expect(target.champion).to be_a(NexosisApi::AlgorithmContestant)
        expect(target.contestants).to be_a(Array)
        expect(target.contestants.length).to be(2)
        expect(target.champion_metric).to eql('macroAverageF1Score')
      end
    end
  end
end

describe NexosisApi::SessionSelectionMetrics do
  describe '#initialize' do
    context 'given selection hash' do
      it 'creates new object initialized with values' do
        metric_hash = session_hash
        metric_hash['metricSets'] = [
          {
            'dataSetProperties' => [
              'Imputed',
              'Scaled'
            ],
            'metrics' => {
              'coefficientOfVariation': 0.74325743456980464,
              'mean': 4.514492753623192,
              'observationCount': 138,
              'trainingCount': 111,
              'standardDeviation': 3.3554303024419467,
              'featureCount': 3,
              'testCount': 27
            }
          }
        ]
        target = NexosisApi::SessionSelectionMetrics.new(metric_hash)
        expect(target).to_not be_nil
        expect(target.session_id).to eql('015ca6f7-ca42-49de-9601-f5493a03cbfa')
        expect(target.dataset_properties.length).to eql(2)
        expect(target.metrics.length).to eql(7)
      end
    end
  end
end

describe NexosisApi::AnomalyScores do
  describe '#initialize' do
    context 'given a score hash' do
      it 'creates a new object initialized with values' do
        score_hash = session_hash
        score_hash['data'] = [{
          'anomaly': '0.07749305',
          'feat1': '-0.24746'
        },
        {
          'anomaly': '0.06584757',
          'feat1': '0.30979'
        }]
        score_hash['metrics'] = { 'percentAnomalies' => 0.10014 }
        target = NexosisApi::AnomalyScores.new(score_hash)
        expect(target.data).to be_a(NexosisApi::PagedArray)
        expect(target.data.page_number).to eql(0)
        expect(target.data.length).to eql(2)
        expect(target.percent_anomalies).to eql(0.10014)
        expect(target.session_id).to eql('015ca6f7-ca42-49de-9601-f5493a03cbfa')
      end
    end
  end
end

describe NexosisApi::ClassifierScores do
  describe '#initialize' do
    context 'given a score hash' do
      it 'creates a new object initialized with values' do
        score_hash = session_hash
        score_hash['data'] = [{
          'target': 'someclass',
          'target:someclass': '7.6',
          'target:otherclass': '5.1',
          'target:anotherclass': '2.2'
        },
        {
          'target': 'anotherclass',
          'target:someclass': '2.6',
          'target:otherclass': '5.1',
          'target:anotherclass': '6.2'
        }]
        score_hash['metrics'] = { 'macroAverageF1Score' => 0.924 }
        score_hash['classes'] = ['someclass', 'otherclass', 'anotherclass']
        target = NexosisApi::ClassifierScores.new(score_hash)
        expect(target.data).to be_a(NexosisApi::PagedArray)
        expect(target.data.page_number).to eql(0)
        expect(target.data.length).to eql(2)
        expect(target.metrics.length).to eql(1)
        expect(target.classes.length).to eql(3)
        expect(target.session_id).to eql('015ca6f7-ca42-49de-9601-f5493a03cbfa')
      end
    end
  end
end

private

def session_hash
  { 'sessionId': '015ca6f7-ca42-49de-9601-f5493a03cbfa',
    'type': 'forecast',
    'status': 'completed',
    'requestedDate': '2017-06-14T14:17:56.012548+00:00',
    'statusHistory': [{ 'date': '2017-06-14T14:17:56.012548+00:00', 'status': 'requested' },
                      { 'date': '2017-06-14T14:17:57.0034498+00:00', 'status': 'started' },
                      { 'date': '2017-06-14T14:18:05.1763039+00:00', 'status': 'completed' }],
    'extraParameters': {},
    'columns': {},
    'dataSourceName': 'RubyTest',
    'targetColumn': 'sales',
    'startDate': '2017-01-22T00:00:00+00:00',
    'endDate': '2017-02-22T00:00:00+00:00',
    'callbackUrl': nil,
    'resultInterval': nil,
    'pageNumber': 0,
    'totalPages': 369,
    'pageSize': 10,
    'totalCount': 3685 }
end

def contestant_array
  [
    {
      'id': '01604c19-60a6-4dbc-a8b6-68fadbe180d4',
      'algorithm': {
        'name': 'Neural Net Tanh',
        'description': 'Neural Network using Hyperbolic Tangent activation function',
        'key': 'nn_tanh_classification'
      },
      'dataSourceProperties': [
        'Imputed',
        'Scaled'
      ],
      'metrics': {
        'macroAverageF1Score': 0.66868686868686877,
        'accuracy': 0.77777777777777779,
        'macroAveragePrecision': 0.69393939393939386,
        'macroAverageRecall': 0.69696969696969691,
        'matthewsCorrelationCoefficient': 0.75047428290868912
      },
      'links': []
    },
    {
      'id': '01604c17-810c-42d0-9332-6db306cca7ef',
      'algorithm': {
        'name': 'SVC Sigmoid',
        'description': 'Support Vector Classification using Sigmoid kernel',
        'key': 'svc_sigmoid'
      },
      'dataSourceProperties': [
        'Imputed',
        'Scaled'
      ],
      'metrics': {
        'macroAverageF1Score': 0.64848484848484855,
        'accuracy': 0.70370370370370372,
        'macroAveragePrecision': 0.70454545454545459,
        'macroAverageRecall': 0.63636363636363635,
        'matthewsCorrelationCoefficient': 0.67033049633031272
      },
      'links': []
    }
  ]
end

def contestant_hash
  {
    'id': '01604c19-60a6-4dbc-a8b6-68fadbe180d4',
    'algorithm': {
      'name': 'Neural Net Tanh',
      'description': 'Neural Network using Hyperbolic Tangent activation function',
      'key': 'nn_tanh_classification'
    },
    'dataSourceProperties': [
      'Imputed',
      'Scaled'
    ],
    'metrics': {
      'macroAverageF1Score': 0.66868686868686877,
      'accuracy': 0.77777777777777779,
      'macroAveragePrecision': 0.69393939393939386,
      'macroAverageRecall': 0.69696969696969691,
      'matthewsCorrelationCoefficient': 0.75047428290868912
    },
    'links': []
  }
end
