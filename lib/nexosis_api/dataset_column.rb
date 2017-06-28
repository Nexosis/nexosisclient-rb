module NexosisApi
    # class to hold the parsed results of a dataset column
    class DatasetColumn
        def initialize(column_name, value_hash)
            @name = column_name
            @type = NexosisApi::ColumnType.const_get(value_hash["dataType"].upcase) unless value_hash["dataType"].nil?
            @role = NexosisApi::ColumnRole.const_get(value_hash["role"].upcase) unless value_hash["role"].nil?
        end
        # The column header, label, or name
        # @return [String]
        attr_accessor :name


        # The data type of this column
        # @note Either string, numeric, logical, or date
        # @return [NexosisApi::ColumnType]
        attr_accessor :type

        # The role of this column
        # @note Either none, timestamp, target, or feature
        # @return [NexosisApi::ColumnRole]
        attr_accessor :role
    end
end