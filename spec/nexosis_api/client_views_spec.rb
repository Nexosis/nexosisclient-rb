require 'helper'

describe NexosisApi::Client::Views do

  before(:all) do
    # load another dataset to use in right side of joins
    data = CSV.open('spec/fixtures/sampledata.csv', 'rb', headers: true)
    test_client.create_dataset_csv('TestRuby_Right', data)
  end

  after(:all) do
    test_client.remove_dataset('TestRuby_Right', cascade_view: true)
  end

  describe '#list_views', :vcr => {:cassette_name => 'list_views'} do
    context 'given existing views' do
      it 'returns all views' do
        test_client.create_view 'TestRubyView_List', 'TestRuby', 'TestRuby_Right'
        actual = test_client.list_views
        expect(actual).to_not be_empty
        expect(actual[0]).to be_a(NexosisApi::ViewDefinition)
        test_client.remove_view('TestRubyView_List')
      end
    end
  end

  describe '#create_view', :vcr => {:cassette_name => 'create_view'} do
    context 'given two existing datasets' do
      it 'creates a view as join of both' do
        actual = test_client.create_view 'TestRubyView', 'TestRuby', 'TestRuby_Right'
        expect(actual).to be_a(NexosisApi::ViewDefinition)
      end
    end
  end

  describe '#create_view', :vcr => {:cassette_name => 'create_view_columns'} do
    context 'given a dataset without defaults' do
      it 'creates metadata on view reference' do
        view_definition = NexosisApi::ViewDefinition.new({})
        view_definition.view_name = 'TestRubyView_ByDef'
        view_definition.dataset_name = 'TestRuby'
        columns = []
        columns << NexosisApi::Column.new('sales', 'dataType' => 'numeric', 'role' => 'target' )
        columns << NexosisApi::Column.new('transactions', 'dataType' => 'numeric', 'role' => 'feature' )
        view_definition.column_metadata = columns
        view_definition.joins = [NexosisApi::Join.new('dataSet' => { 'name' => 'TestRuby_Right' })]
        actual = test_client.create_view_by_def view_definition
        expect(actual).to be_a(NexosisApi::ViewDefinition)
        expect(actual.column_metadata.length).to eql(3)
        expect(actual.column_metadata[2].role).to eql(:feature)
      end
    end
  end

  describe 'viewsummary#to_json' , :vcr => {:cassette_name => 'view_summary_json'} do
    context 'given an object with values set' do
      it 'outputs a valid json string' do
        view_definition = NexosisApi::ViewDefinition.new({})
        view_definition.dataset_name = 'testdataset'
        join = NexosisApi::Join.new('dataSet' => { 'name' => 'right_datasource_name' })
        view_definition.joins = [join]
        actual = view_definition.to_json
        expect(actual).to eql('{"dataSetName":"testdataset","joins":[{"dataSet":{"name":"right_datasource_name"}}]}')
      end
    end
  end

  describe '#remove_view', :vcr => {:cassette_name => 'remove_view'} do
    context 'given an existing view' do
      it 'removes the view' do
        test_client.create_view 'TestRubyView_Remove', 'TestRuby', 'TestRuby_Right'
        test_client.remove_view 'TestRubyView_Remove'
        actual = test_client.list_views 'TestRubyView_Remove'
        expect(actual).to be_empty
      end
    end
  end

  describe '#get_view', :vcr => {:cassette_name => 'get_view_data'} do
    context 'given an existing view' do
      it 'retrieves the data of the view' do
        test_client.create_view 'TestRubyView_Data', 'TestRuby', 'TestRuby_Right'
        actual = test_client.get_view 'TestRubyView_Data'
        expect(actual).to be_a(NexosisApi::ViewData)
        expect(actual.column_metadata.length).to eql(3)
        expect(actual.view_name).to eql('TestRubyView_Data')
      end
    end
  end

  describe '#get_view', :vcr => {:cassette_name => 'get_view_daterange'} do
    context 'given a range of dates' do
      it 'retrieves the view data within range' do
        start_date = Date.parse('05-01-2014')
        end_date = Date.parse('05-10-2014')
        test_client.create_view 'TestRubyView_DataDates', 'TestRuby', 'TestRuby_Right'
        actual = test_client.get_view 'TestRubyView_DataDates', 0, 10, {'start_date': start_date, 'end_date': end_date}
        expect(actual).to be_a(NexosisApi::ViewData)
        expect(actual.data.length).to eql(10)
        actual.data.each do |datum|
          expect(Date.parse(datum['timeStamp'])).to be_between(start_date, end_date).inclusive
        end
      end
    end
  end

  describe '#get_view', :vcr => {:cassette_name => 'get_view_columns'} do
    context 'given a set of columns' do
      it 'retrieves only the given columns' do
        test_client.create_view 'TestRubyView_DataCols', 'TestRuby', 'TestRuby_Right'
        actual = test_client.get_view 'TestRubyView_DataCols', 0, 1, 'include': %w[sales transactions]
        expect(actual).to be_a(NexosisApi::ViewData)
        expect(actual.data.first).to_not be_nil
      end
    end
  end

  describe '#create_view' do
    context 'given no view_name' do
      it 'raises ArgumentError' do
        expect { test_client.create_view '', '', ''}.to raise_error { |error|
          expect(error).to be_a(ArgumentError)
       }
      end
    end
  end

  describe '#remove_view' do
    context 'given no view_name' do
      it 'raises ArgumentError' do
        expect { test_client.remove_view ''}.to raise_error { |error|
          expect(error).to be_a(ArgumentError)
       }
      end
    end
  end

  describe '#create_view_by_def', :vcr => {:cassette_name => 'create_calendar_view'} do
    context 'given a view with calendar' do
      it 'creates view' do
        definition = NexosisApi::ViewDefinition.new({'viewName' => 'TestViewCal', 'dataSetName' => 'TestRuby', 'joins' => [{ 'calendar' => { 'name' => 'Nexosis.Holidays-US' } } ] })
        actual = test_client.create_view_by_def definition
        expect(actual).to_not be_nil
        expect(actual.joins[0].join_target).to_not be_nil
        expect(actual.joins[0].join_target).to be_a(NexosisApi::CalendarJoinTarget)
        test_client.remove_view 'TestViewCal'
      end
    end
  end

  describe '#create_view_by_def', :vcr => {:cassette_name => 'create_aliased_view'} do
    context 'given datasets with matching columns' do
      it 'includes both by alias' do
        definition = NexosisApi::ViewDefinition.new({'viewName' => 'TestViewAlias', 'dataSetName' => 'TestRuby', 'joins' => [{ 'dataSet' => { 'name' => 'TestRuby_Right' }, 'columnOptions' => { 'transactions' => { 'alias' => 'othertransactions' } } } ] })
        actual = test_client.create_view_by_def definition
        expect(actual).to_not be_nil
        expect(actual.joins[0].join_target).to_not be_nil
        expect(actual.joins[0].join_target).to be_a(NexosisApi::DatasetJoinTarget)
        expect(actual.column_metadata[2].name).to eql('othertransactions')
        test_client.remove_view 'TestViewAlias'
      end
    end
  end
end
