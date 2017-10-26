module NexosisApi
  # Specifies the name of a dataset to use as the join datasource
  # @see http://docs.nexosis.com/guides/views
  # @since 1.2.3
  class DatasetJoinTarget
    def initialize(ds_join_hash)
      @dataset_name = ds_join_hash['name'] unless ds_join_hash.nil?
    end
    
    # The name of the dataset that will be participating in the join
    # @return [String] name of the dataset provided for this join
    attr_accessor :dataset_name
    
    # provides a custom hash to match api requests
    def to_hash
      { 'dataSet' => { 'name' => dataset_name } }
    end
  end
end