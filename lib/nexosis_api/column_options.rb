module NexosisApi
  # Class for holding the join options on a column in a view-based join
  # @since 1.2.0
  class ColumnOptions
    # Create a new option for a join column.
    # @param column_name [String] the name of the original column from the source dataset
    # @param options_hash [Hash] additional information about how to process the column in a join
    def initialize(column_name, options_hash)
      @column_name = column_name
      @join_interval = NexosisApi::TimeInterval.const_get(options_hash['joinInterval'].upcase) unless options_hash['joinInterval'].nil?
      @alias = options_hash['alias']
    end

    # The name of the column on which these options are applied
    # @return [String]
    attr_accessor :column_name

    # Optional interval of a time series column being joined to another time series
    # @note not valid outside of join defintion
    # @return [NexosisApi::TimeInterval]
    attr_accessor :join_interval

    # Optional alias of the column when participating in a join
    # @note An alias can be used to keep two same-named columns distinct
    # or to merge two distinctly named columns. By default same-named columns
    # on two sides of a join will be merged.
    # @return [String]
    attr_accessor :alias

    # builds a custom hash which will match api requests
    def to_hash
      hash = { column_name => {} }
      hash[column_name]['join_interval'] = join_interval.to_s unless join_interval.nil?
      hash[column_name]['alias'] = @alias.to_s unless @alias.nil?
      hash
    end
  end
end
