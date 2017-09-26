require 'helper'
require 'csv'
require 'json'

describe NexosisApi::Client::Models do
  describe '#create_dataset_json', :vcr => {:cassette_name => 'create_dataset_json'} do
    context 'given a dataset json hash' do
      it 'returns a dataset summary' do