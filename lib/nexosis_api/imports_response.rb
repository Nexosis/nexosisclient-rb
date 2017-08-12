module NexosisApi
    # class to parse results from an imports call
    class ImportsResponse
        def initialize(response_hash)
            response_hash.each do |k,v|
                if(k == "importId")
                    @import_id = v
                elsif(k == "requestedDate")
                    @requested_date = v
                elsif(k == "columns")
                    columns = []
                    next if v.nil?
                    v.keys.each do |col_key|
                        columns << NexosisApi::Column.new(col_key, v[col_key])
                    end
                    @column_metadata = columns
                elsif(k == "links")
					links = Array.new
					v.each do |l| links << NexosisApi::Link.new(l) end
					instance_variable_set("@#{k}", links) unless v.nil?
                else
                   instance_variable_set("@#{k}", v) unless v.nil?
                end
            end
        end

        # The unique identifier for this import request
        # @return [String]
        attr_accessor :import_id

        # Currently always s3
        # @return [String]
        attr_accessor :type, :s3 
        
        # The current status of the import request
        # @return [String]
        # @note The import will be performed in a FIFO queue. Check back on status before attempting to start a session using the dataset.
        attr_accessor :status

        # echo back the dataset name provided
        # @return [String]
        attr_accessor :dataSetName

        # The S3 parameters used to import a dataset
        # @return [Hash]
        # For an S3 response the keys of this hash should be 'bucket', 'path', and 'region'
        attr_accessor :parameters

        # The date of the import request
        # @return [DateTime]
        attr_accessor :requested_date

        # Additional details. Normally empty.
        # @return [Array]
        attr_accessor :messages

		# The column descriptors for the data in this session
		#    will reflect either the metadata sent in, defaults form dataset, or inferred values
		# @return[Array of NexosisApi::Column]
        attr_accessor :column_metadata

        # associated hypermedia
		# @return [Array of NexosisApi::Link]
		attr_accessor :links
    end
end