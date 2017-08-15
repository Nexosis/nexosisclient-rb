module NexosisApi
  # class to hold the parsed results of a view
  class ViewDefinition
    def initialize(view_hash)
      view_hash.each do |k, v|
        if k == 'viewName'
          @view_name = v unless v.nil?
        elsif k == 'datasetName'
          @dataset_name = v unless v.nil?
        elsif k == 'columns'
          columns = []
          next if v.nil?
          v.keys.each do |col_key|
            columns << NexosisApi::Column.new(col_key, v[col_key])
          end
          @column_metadata = columns
        elsif k == 'joins'
          joins = []
          v.each do |join|
            joins << NexosisApi::Join.new(join)
          end
          @joins = joins
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
