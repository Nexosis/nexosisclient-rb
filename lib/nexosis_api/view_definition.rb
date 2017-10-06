module NexosisApi
  # class to hold the parsed results of a view
  # @since 1.2.0
  class ViewDefinition
    def initialize(view_hash)
      view_hash.each do |k, v|
        if k == 'viewName'
          @view_name = v unless v.nil?
        elsif k == 'dataSetName'
          @dataset_name = v unless v.nil?
        elsif k == 'columns'
          next if v.nil?
          @column_metadata = v.reject { |value| value.nil? } .map { |col_name, col_hash| NexosisApi::Column.new(col_name, col_hash)}
        elsif k == 'joins'
          next if v.nil?
          @joins = v.reject(&:nil?).map { |join| NexosisApi::Join.new(join) }
        elsif k == 'isTimeSeries'
          @is_timeseries = v
        end
      end
    end

    # The name of the view uploaded and saved
    # @return [String]
    attr_accessor :view_name

    # The name of the dataset on the left of the join
    # @return [String]
    attr_accessor :dataset_name

    # Descriptive information about the columns
    # @return [Array of NexosisApi::Column]
    attr_accessor :column_metadata

    # The join configuration for this view
    # @return [Array of NexosisApi::Join]
    attr_accessor :joins

    # Is this view based on time series data?
    # @since 1.3.0
    attr_accessor :is_timeseries
    
    # Is this view based on time series data?
    # @since 1.3.0
    alias_method :timeseries?, :is_timeseries

    def to_json
      hash = {}
      hash['dataSetName'] = dataset_name
      if column_metadata.nil? == false
        hash['columns'] = {}
        column_metadata.each do |column|
          hash['columns'].merge!(column.to_hash)
        end
      end
      hash['joins'] = []
      joins.each do |join|
        hash['joins'] << join.to_hash
      end
      hash.to_json
    end
  end
end
