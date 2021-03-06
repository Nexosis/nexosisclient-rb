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

describe NexosisApi::VocabularySummary do
  describe '#initialize' do
    context 'given a vocab hash' do
      it 'creates a new object initialized with values' do
        target = NexosisApi::VocabularySummary.new(vocabulary_summary_hash)
        expect(target.datasource_name).to eql('TestDS')
        expect(target.links[0].rel).to eql('words')
        expect(target.column_name).to eql('text')
        expect(target.datasource_type).to eql('dataSet')
      end
    end
  end
end

describe NexosisApi::VocabularyWord do
  describe '#initialize' do
    context 'given a vocab hash' do
      it 'creates a new object initialized with values' do
        target = NexosisApi::PagedArray.new(vocabulary_word_list,
                                        vocabulary_word_list['items']
                                        .map { |word| NexosisApi::VocabularyWord.new(word) })
        expect(target[0]).to be_a(NexosisApi::VocabularyWord)
        expect(target.length).to eql(2)
        expect(target[0].text).to eql('thank')
      end
    end
  end
end

describe NexosisApi::FeatureImportance do
  describe '#initialize' do
    context 'given a feature importance hash' do
      it 'creates a new object initialized with values' do
        target = NexosisApi::FeatureImportance.new(feature_importance_hash)
        expect(target).to_not be_nil
        expect(target.session_id).to eql('016291b7-d8e0-40be-818d-09d8cea3c4d1')
        expect(target.status_history.length).to eql(3)
        expect(target.scores).to be_a(NexosisApi::PagedArray)
        expect(target.scores.to_h.keys.map &:to_s).to eql(['petal_len', 'sepal_len', 'petal_width', 'sepal_width'])
      end
    end

    context 'given a string keyed hash' do
      it 'still find feature importance scores' do
        target = NexosisApi::FeatureImportance.new({'featureImportance' => {'foo': 1.0 }})
        expect(target.scores).to_not be_nil
      end
    end
  end
end

describe NexosisApi::DistanceMetric do
  describe '#initialize' do
    context 'given a single metric row' do
      it 'creates a new metric object with values' do
        distance_row = {
          'anomaly': '0.0287059555836055',
          'Ash': '2.45',
          'Hue': '0.64',
          'Alcohol': '13.71',
          'ODRatio': '1.74',
          'Proline': '740',
          'mahalanobis_distance': '102.301222289665'
        }
        actual = NexosisApi::DistanceMetric.new(distance_row)
        expect(actual).to_not be_nil
        expect(actual.anomaly_score).to eql(0.0287059555836055)
        expect(actual.distance).to eql(102.301222289665)
        expect(actual.data.length).to eql(5)
      end
    end
  end
end

describe NexosisApi::AnomalyDistances do
  describe '#initialize' do
    context 'given a distance response hash' do
      it 'creates a new distance objects with values' do
        actual = NexosisApi::AnomalyDistances.new(distance_hash)
        expect(actual).to_not be_nil
        expect(actual.data.length).to eql(2)
        expect(actual.data.total_pages).to eql(89)
        expect(actual.session_id).to eql('01623eba-7d13-46ba-801f-45205ea96106')
      end
    end
  end
end

describe NexosisApi::Outlier do
  describe '#initialize' do
    context 'given a record hash of outlier' do
      it 'creates a new outlier with values' do
        actual = NexosisApi::Outlier.new('timeStamp': '1/5/2014 12:00:00 AM',
                                         'sales:actual': '229.09',
                                         'sales:smooth': '1743.42167102697')
        expect(actual).to_not be_nil
        expect(actual.smoothed).to eql(1743.42167102697)
        expect(actual.actual).to eql(229.09)
        expect(actual.timestamp).to eql(DateTime.parse('1/5/2014 12:00:00 AM'))
      end
    end
  end
end

describe NexosisApi::TimeseriesOutliers do
  describe '#initialize' do
    context 'given an outlier response hash' do
      it 'creates a new outliers object with values' do
        actual = NexosisApi::TimeseriesOutliers.new(outliers_hash)
        expect(actual).to_not be_nil
        expect(actual.data.length).to eql(2)
        expect(actual.data.total_pages).to eql(1)
        expect(actual.session_id).to eql('01626ca6-56b2-417a-8ea1-6b05bbe389c6')
      end
    end
  end
end

describe NexosisApi::ListQuery do
  describe '#initialize' do
    context 'given a list query hash' do
      it 'creates a new query object' do
        query = { 'page_size': 10, 'page_number': 1, 'sort_by': 'foo', 'sort_order': 'asc' }
        actual = NexosisApi::ListQuery.new(query)
        expect(actual.page_number).to eql(1)
        expect(actual.page_size).to eql(10)
        expect(actual.sort_by).to eql('foo')
        expect(actual.sort_order).to eql(NexosisApi::SortOrder::ASC)
      end
    end
  end

  describe '#page_size' do
    context 'when setting a property' do
      it 'overrides initial values' do
        target = NexosisApi::ListQuery.new()
        original = target.page_size
        target.page_size = 5
        expect(original).to_not eql(5)
      end
    end
  end

  describe '#to_hash' do
    context 'given only some properties' do
      it 'provides a hash with only those props' do
        target = NexosisApi::ListQuery.new(sort_by: 'foo')
        actual = target.to_hash
        expect(actual.length).to eql(3)
        expect(actual.fetch(:sortBy)).to eql('foo')
      end
    end
  end
end

describe NexosisApi::SessionListQuery do
  describe '#initialize' do
    context 'given a list query hash' do
      it 'creates a new query object' do
        query = { 'sort_by': 'foo', 'sort_order': 'desc', 'event_name': 'bar' }
        actual = NexosisApi::SessionListQuery.new(query)
        expect(actual.page_number).to eql(0)
        expect(actual.page_size).to eql(50)
        expect(actual.sort_by).to eql('foo')
        expect(actual.sort_order).to eql(NexosisApi::SortOrder::DESC)
        expect(actual.event_name).to eql('bar')
      end
    end

    context 'given dates' do
      it 'queries those dates' do
        query = NexosisApi::SessionListQuery.new(requested_before_date: DateTime.new(2007, 11, 19, 8, 37, 48, '-06:00'))
        actual = query.query_parameters
        expect(actual[:requestedBeforeDate]).to eql('2007-11-19T08:37:48-06:00')
      end
    end

    context 'given an invalid option' do
      it 'raises an argument error' do
        expect{ NexosisApi::SessionListQuery.new(not_found_option: 'causes exception') }.to raise_error(ArgumentError)
      end
    end
  end
end

describe NexosisApi::ModelListQuery do
  describe '#query_parameters' do
    context 'given a filled query object' do
      it 'gets hash of super and instance values' do
        target = NexosisApi::ModelListQuery.new({page_number: 1, datasource_name: 'test-dataset', created_after_date: '14/1/2017'})
        actual = target.query_parameters
        expect(actual[:dataSourceName]).to eql('test-dataset')
        expect(actual[:pageSize]).to eql(50)
        expect(actual[:createdAfterDate]).to eql('2017-01-14T00:00:00+00:00')
      end
    end

    context 'given no parameters' do
      it 'doesnt put key in hash' do
        target = NexosisApi::ModelListQuery.new(page_number: 1)
        actual = target.query_parameters
        expect(actual[:dataSourceName]).to be_nil
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

def vocabulary_summary_hash
  {
    'id': '6e0d9884-a5a5-4a30-b9f1-fea8380be51e',
    'dataSourceName': 'TestDS',
    'columnName': 'text',
    'dataSourceType': 'dataSet',
    'createdOnDate': '2018-01-22T19:25:18.6662961+00:00',
    'createdBySessionId': '01611f54-7568-4a52-8693-a6c3d77b3964',
    'links' => [{
      'rel': 'words',
      'href': 'https://ml.nexosis.com/v1/vocabulary/6e0d9884-a5a5-4a30-b9f1-fea8380be51e'
    }]
  }
end

def vocabulary_word_list
  {
    'items'=> [
      {
        'text': 'thank',
        'type': 'word',
        'rank': 8
      }, {
        'text': 'just',
        'type': 'word',
        'rank': 9
      }
    ],
    'pageNumber': 0,
    'totalPages': 1423,
    'pageSize': 10,
    'totalCount': 14228,
    'links': [{
      'rel': 'self',
      'href': 'https://api.uat.nexosisdev.com/v1/vocabulary/6e0d9884-a5a5-4a30-b9f1-fea8380be51e?type=Word&page=0&pageSize=10'
    }, {
      'rel': 'first',
      'href': 'https://api.uat.nexosisdev.com/v1/vocabulary/6e0d9884-a5a5-4a30-b9f1-fea8380be51e?type=Word&page=0&pageSize=10&page=0'
    }]
  }
end

def feature_importance_hash 
  {
    'featureImportance': {
        'petal_len': 1,
        'sepal_len': 0.59862634386248159,
        'petal_width': 1,
        'sepal_width': 0.32464203040032896
    },
    "pageNumber": 0,
    "totalPages": 4,
    "pageSize": 100,
    "totalCount": 351,
    'sessionId': '016291b7-d8e0-40be-818d-09d8cea3c4d1',
    'type': 'model',
    'status': 'completed',
    'predictionDomain': 'classification',
    'supportsFeatureImportance': true,
    'availablePredictionIntervals': [],
    'modelId': '4d9fdf0d-6f98-4317-b85f-a8548d38ee89',
    'requestedDate': '2018-04-04T17:32:47.681627+00:00',
    'statusHistory': [
        {
            'date': '2018-04-04T17:32:47.681627+00:00',
            'status': 'requested'
        },
        {
            'date': '2018-04-04T17:32:47.9512586+00:00',
            'status': 'started'
        },
        {
            'date': '2018-04-04T17:41:54.1412943+00:00',
            'status': 'completed'
        }
    ],
    'extraParameters': {
        'balance': true
    },
    'messages': [
        {
            'severity': 'informational',
            'message': '2237 observations were found in the dataset.'
        }
    ],
    'name': 'Classification on Iris',
    'dataSourceName': 'Iris',
    'dataSetName': 'Iris',
    'targetColumn': 'iris',
    'algorithm': {
        'name': 'K-Nearest Neighbors',
        'description': 'K-Nearest Neighbors',
        'key': ''
    },
    'isEstimate': false,
    'links': [
        {
            'rel': 'data',
            'href': 'https://api.uat.nexosisdev.com/v1/data/Iris'
        }]
  }
end

def distance_hash
  {
    'metrics': {
        'percentAnomalies': 0.10112359550561797
    },
    'data': [
        {
            'anomaly': '0.0487072268545709',
            'Ash': '2',
            'Hue': '0.93',
            'Alcohol': '12',
            'ODRatio': '3.05',
            'Proline': '564',
            'mahalanobis_distance': '143.312589889491'
        },
        {
            'anomaly': '0.000317797613019206',
            'Ash': '2.28',
            'Hue': '1.25',
            'Alcohol': '12.33',
            'ODRatio': '1.67',
            'Proline': '680',
            'mahalanobis_distance': '156.112291933161'
        }
    ],
    'pageNumber': 0,
    'totalPages': 89,
    'pageSize': 2,
    'totalCount': 178,
    'sessionId': '01623eba-7d13-46ba-801f-45205ea96106',
    'type': 'model',
    'status': 'completed',
    'predictionDomain': 'anomalies',
    'supportsFeatureImportance': false,
    'availablePredictionIntervals': [],
    'modelId': '1d557a30-f78e-434a-b52f-4abafd183da3',
    'requestedDate': '2018-03-19T14:47:11.856205+00:00',
    'statusHistory': [
        {
            'date': '2018-03-19T14:47:11.856205+00:00',
            'status': 'requested'
        },
        {
            'date': '2018-03-19T14:47:12.2708536+00:00',
            'status': 'started'
        },
        {
            'date': '2018-03-19T14:47:33.505159+00:00',
            'status': 'completed'
        }
    ],
    'extraParameters': {
        'containsAnomalies': true
    },
    'messages': [
        {
            'severity': 'informational',
            'message': '178 observations were found in the dataset.'
        }
    ],
    'name': 'WineNoTarget',
    'dataSourceName': 'Wine',
    'dataSetName': 'Wine',
    'targetColumn': 'anomaly',
    'algorithm': {
      'name': 'Isolation Forest',
      'description': 'Isolation Forest Outlier Detection',
      'key': 'isolation_forest_anomalies'
    },
    'isEstimate': false,
    'links': [
        {
            'rel': 'data',
            'href': 'https://api.uat.nexosisdev.com/internal/data/Wine'
        }
    ]
}
end

def outliers_hash
  {
    'data': [
        {
            'timeStamp': '1/5/2014 12:00:00 AM',
            'sales:actual': '229.09',
            'sales:smooth': '1743.42167102697'
        },
        {
            'timeStamp': '1/6/2014 12:00:00 AM',
            'sales:actual': '0',
            'sales:smooth': '1920.29538270229'
        }
    ],
    'pageNumber': 0,
    'totalPages': 1,
    'pageSize': 2,
    'totalCount': 2,
    'sessionId': '01626ca6-56b2-417a-8ea1-6b05bbe389c6',
    'type': 'forecast',
    'status': 'completed',
    'predictionDomain': 'forecast',
    'supportsFeatureImportance': true,
    'availablePredictionIntervals': [
        '0.2',
        '0.5',
        '0.8'
    ],
    'startDate': '2016-10-10T00:00:00+00:00',
    'endDate': '2016-11-10T00:00:00+00:00',
    'resultInterval': 'day',
    'requestedDate': '2018-03-28T12:47:43.219102+00:00',
    'statusHistory': [
        {
            'date': '2018-03-28T12:47:43.219102+00:00',
            'status': 'requested'
        },
        {
            'date': '2018-03-28T12:49:02.1659862+00:00',
            'status': 'started'
        },
        {
            'date': '2018-03-28T13:04:04.8297598+00:00',
            'status': 'completed'
        }
    ],
    'extraParameters': {},
    'messages': [
    ],
    'name': 'Forecast on LocationAFull',
    'dataSourceName': 'LocationAFull',
    'dataSetName': 'LocationAFull',
    'targetColumn': 'sales',
    'algorithm': {
        'name': 'Additive Model, Weekly + Annual',
        'description': 'Forecasts time series in a way robust to outliers, missing data, and dramatic changes to time series, with a weekly + annual seasonal component',
        'key': 'PROPHET+W+A'
    },
    'isEstimate': false,
    'links': [
        {
            'rel': 'data',
            'href': 'https://api.uat.nexosisdev.com/internal/data/LocationAFull'
        }
    ]
}
end