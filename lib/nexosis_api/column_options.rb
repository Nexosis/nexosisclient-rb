module NexosisApi
  # Class for holding the join options on a column in a view-based join
  # @since v1.2
  class ColumnOptions
    # Create a new option for a join column.
    # @param column_name [String] the name of the original column from the source dataset
    # @param options_hash [Hash] additional information about how to process the column in a join
    def initialize(column_name, options_hash)
      @name = column_name
      @join_interval = NexosisApi::TimeInterval.const_get(options_hash['joinInterval'].upcase) unless options_hash['joinInterval'].nil?
      @alias = options_hash['alias']
    end

    attr_accessor :name

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

    def to_hash
      { name => { 'join_interval' => @join_internal.to_s,
                  'alias' => @alias.to_s } }
    end
  end
end