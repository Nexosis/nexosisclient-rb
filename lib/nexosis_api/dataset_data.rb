module NexosisApi
  # class to hold the parsed results of a dataset
  class DatasetData
    def initialize(data_hash)
      data_hash.each do |k, v|
        if (k == 'data')
          @data = NexosisApi::PagedArray.new(data_hash, v)
        elsif (k == 'links')
          @links = v.reject(&:nil?).map { |l| NexosisApi::Link.new(l) }
        elsif (k == 'isTimeSeries')
          @is_timeseries = v
        end
      end
    end

    # Helpful links to more information about this dataset
    # @return [Array of NexosisApi::Link]
    attr_accessor :links

    # The hash of data values from the dataset
    # @return [NexosisApi::PagedArray of Hash] where each hash contains the dataset data
    attr_accessor :data

    # Whether or not this dataset was loaded with a date-based key with a timestamp role
    # @return [Boolean]
    # @since 2.1.1
    attr_reader :is_timeseries
  end
end
