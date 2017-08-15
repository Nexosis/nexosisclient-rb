# frozen_string_literal: true

module NexosisApi
  # class to hold a join defintion initialized by a hash of join values
  class Join
    def initialize(join_hash)
      join_hash.each do |k, v|
        if k == 'dataSetName'
          @dataset_name = v unless v.nil?
        elsif k == 'column_options'
          @column_options = v unless v.nil?
        elsif k == 'joins'
          joins = []
          v&.each do |join|
            joins << NexosisApi::Join.new(join)
            @joins = joins
          end
        end
      end
    end

    # The name of the dataset that will be participating in the join
    # @return [String] the dataset name provided for this join
    attr_accessor :dataset_name

    # The optional column definition for the join which
    # defines how columns should be used from the joined dataset
    # @return [Array of NexosisApi::ColumnOptions] column options definition
    attr_accessor :column_options

    # Optional additional data source to be joined to this data source
    # @return [Array of NexosisApi::Join] zero or more additional joins
    attr_accessor :joins

    def to_hash
      hash = {}
      hash['dataSetName'] = dataset_name.to_s
      if column_options.nil? == false
        hash['columns'] = {}
        column_options.each do |column|
          hash['columns'].merge!(column.to_hash)
        end
      end
      if joins.nil? == false
        hash['joins'] = []
        joins.each do |join|
          hash['joins'] << join.to_hash
        end
      end
      hash
    end

    def to_json
      to_hash.to_json
    end
  end
end
