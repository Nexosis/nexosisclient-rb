module NexosisApi
  # class to hold the parsed results of a dataset
  class DatasetData
    def initialize(data_hash)
      data_hash.each do |k, v|
        if (k == 'data')
          @data = v
        elsif (k == 'links')
          links = Array.new
          v.each do |l| links << NexosisApi::Link.new(l) end
          @links = links
        end
      end
    end

    # Helpful links to more information about this dataset
    # @return [Array of NexosisApi::Link]
    attr_accessor :links

    #The hash of data values from the dataset
    # @return [Array of Hash] where each hash contains the dataset data
    attr_accessor :data
  end
end
