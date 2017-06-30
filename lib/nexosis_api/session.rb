module NexosisApi
	# Class for parsing the results of a session based request
	class Session
		def initialize(sessionHash)
			sessionHash.each do |k,v|
				if(k == "links")
					links = Array.new
					v.each do |l| links << NexosisApi::Link.new(l) end
					instance_variable_set("@#{k}", links) unless v.nil?
				elsif(k == "isEstimate")
                    instance_variable_set("@is_estimate", v) unless v.nil?
				elsif(k == "columns")
                    columns = []
                    next if v.nil?
                    v.keys.each do |col_key|
                        columns << NexosisApi::DatasetColumn.new(col_key, v[col_key])
                    end
                    @column_metadata = columns
				else
					instance_variable_set("@#{k}", v) unless v.nil?
				end
			end
		end

		# identifier for this sesssion
		# @return [String]
		attr_accessor :sessionId

		# What type of analysis was run during this session
		# @return [String]
		attr_accessor :type

		# Is this session requested, estimated, started, or completed
		# @return [String]
		attr_accessor :status

		# Date and status of each status this session has entered
		# @return [Hash]
		attr_accessor :statusHistory

		# reserved for future extensions
		# @return [Hash]
		attr_accessor :extraParameters

		# the dataset used in this session
		# @return [String]
		attr_accessor :dataSetName

		# The column in the dataset for which this session ran predictions
		# @return [String]
		attr_accessor :targetColumn

		# The start date of analysis in this session
		# @return [DateTime]
		attr_accessor :startDate

		# The end date of analysis in this session
		# @return [DateTime]
		attr_accessor :endDate

		# associated hypermedia
		# @return [Array of NexosisApi::Link]
		attr_accessor :links

		# Is this session an estimate only session
		# @return [Boolean]
		attr_accessor :is_estimate

		# The column descriptors for the data in this session
		#    will reflect either the metadata sent in, defaults form dataset, or inferred values
		# @return[Array of NexosisApi::DatasetColumn]
		attr_accessor :column_metadata
	end
end

