module NexosisApi
  # class to hold the parsed results of a dataset
  class DatasetSummary
    def initialize(data_hash)
      data_hash.each do |k, v|
        if (k == 'dataSetName')
          @dataset_name = v unless v.nil?
        elsif (k == 'columns')
          @column_metadata = v.reject { |_key, value| value.nil? }
                              .map do |col_key, col_val|
                                NexosisApi::Column.new(col_key, col_val)
                              end
        end
      end
    end

    # The name of the dataset uploaded and saved
    # @return [String]
    attr_accessor :dataset_name

    # Descriptive information about the columns
    # @return [Array of NexosisApi::Column]
    attr_accessor :column_metadata

    # Helper method which tells you whether or not this dataset has a column with timestamp role.
    # @note Often helpful for implmenters as non-timeseries datasets
    # cannot be sent to forecast or impact sessions
    # @since 1.3.0
    def timeseries?
      !@column_metadata.select { |dc| dc.role == NexosisApi::ColumnRole::TIMESTAMP }.empty?
    end
  end
end
