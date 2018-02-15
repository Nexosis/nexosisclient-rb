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
        elsif (k == 'dataSetSize')
          @dataset_size = v.to_i
        elsif (k == 'links')
          @links = v.reject(&:nil?).map { |l| NexosisApi::Link.new(l) }
        end
      end
    end

    # The name of the dataset uploaded and saved
    # @return [String]
    attr_accessor :dataset_name

    # Descriptive information about the columns
    # @return [Array of NexosisApi::Column]
    attr_accessor :column_metadata

    # number of estimated bytes required to store the dataset
    # @return [Integer]
    # @since 2.3.0
    attr_reader :dataset_size

    # Helpful links to more information about this dataset
    # @return [Array of NexosisApi::Link]
    # @since 2.3.0
    attr_accessor :links

    # Helper method which tells you whether or not this dataset has a column with timestamp role.
    # @note Often helpful for implmenters as non-timeseries datasets
    # cannot be sent to forecast or impact sessions
    # @since 1.3.0
    def timeseries?
      !@column_metadata.select { |dc| dc.role == NexosisApi::ColumnRole::TIMESTAMP }.empty?
    end
  end
end
