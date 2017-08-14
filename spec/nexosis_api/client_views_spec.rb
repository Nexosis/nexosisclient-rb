require 'helper'

describe NexosisApi::Client::Views do
  # describe '#list_views' do
  #   context 'given existing views' do
  #     it 'returns all views' do
  #       actual = test_client.list_views
  #     end
  #   end
  # end

  describe '#create_view' do
    context 'given two existing datasets' do
      it 'creates a view as join of both' do
        actual = test_client.create_view 'TestRubyView', 'EnvironmentData2', 'EnvironmentDataImputed'
        expect(actual).to be_a(NexosisApi::ViewSummary)
      end
    end
  end

  describe 'viewsummary#to_json' do
    context 'given an object with values set' do
      it 'outputs a valid json string' do
        view_definition = NexosisApi::ViewSummary.new({})
        view_definition.dataset_name = 'testdataset'
        join = NexosisApi::Join.new('dataSetName' => 'right_datasource_name')
        view_definition.joins = [join]
        actual = view_definition.to_json
        expect(actual).to eql('{"dataSetName":"testdataset","joins":[{"dataSetName":"right_datasource_name"}]}')
      end
    end
  end
end
