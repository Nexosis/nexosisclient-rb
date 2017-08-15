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

  describe '#list_views' do
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

  describe '#create_view' do
    context 'given two existing datasets' do
      it 'creates a view as join of both' do
        actual = test_client.create_view 'TestRubyView', 'TestRuby', 'TestRuby_Right'
        expect(actual).to be_a(NexosisApi::ViewDefinition)
      end
    end
  end

  describe '#create_view' do
    context 'given a dataset without defaults' do
      it 'creates metadata on view reference' do
        view_definition = NexosisApi::ViewDefinition.new({})
        view_definition.view_name = 'TestRubyView_ByDef'
        view_definition.dataset_name = 'TestRuby'
        columns = []
        columns << NexosisApi::Column.new('sales', 'dataType' => 'numeric', 'role' => 'target' )
        columns << NexosisApi::Column.new('transactions', 'dataType' => 'numeric', 'role' => 'feature' )
        view_definition.column_metadata = columns
        view_definition.joins = [NexosisApi::Join.new('dataSetName' => 'TestRuby_Right')]
        actual = test_client.create_view_by_def view_definition
        expect(actual).to be_a(NexosisApi::ViewDefinition)
        expect(actual.column_metadata.length).to eql(3)
        expect(actual.column_metadata[2].role).to eql(:feature)
      end
    end
  end

  describe 'viewsummary#to_json' do
    context 'given an object with values set' do
      it 'outputs a valid json string' do
        view_definition = NexosisApi::ViewDefinition.new({})
        view_definition.dataset_name = 'testdataset'
        join = NexosisApi::Join.new('dataSetName' => 'right_datasource_name')
        view_definition.joins = [join]
        actual = view_definition.to_json
        expect(actual).to eql('{"dataSetName":"testdataset","joins":[{"dataSetName":"right_datasource_name"}]}')
      end
    end
  end

  describe '#remove_view' do
    context 'given an existing view' do
      it 'removes the view' do
        test_client.create_view 'TestRubyView_Remove', 'TestRuby', 'TestRuby_Right'
        test_client.remove_view 'TestRubyView_Remove'
        actual = test_client.list_views 'TestRubyView_Remove'
        expect(actual).to be_empty
      end
    end
  end

  describe '#get_view' do
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
end
