module NexosisApi
  # Class to hold the parsed results of a view data retrieval
  class ViewData < ViewDefinition
    def initialize(viewdata_hash)
      @data = viewdata_hash['data']
      super(viewdata_hash.reject { |k| k == 'data' })
    end

    # An array of hashes representing the processed data of the view
    # @return [Array of Hash] - one hash per row of data where key = column name
    attr_accessor :data
  end
end
