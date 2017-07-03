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

        # utility method to format a column description in the way it is expected on input
        def to_hash
            { self.name => { "dataType" => self.type.to_s, "role" => self.role.to_s }} 
        end

        def self.to_json(column_array)
            result = {}
            column_array.each {|col| result[col.to_hash.keys[0]] = col.to_hash.values[0] } 
            result
        end
    end
end