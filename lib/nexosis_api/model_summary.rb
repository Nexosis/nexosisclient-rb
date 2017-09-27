module NexosisApi
  # class to hold the parsed results of model summary json
  # @since 1.3.0
  class ModelSummary
    def initialize(model_hash)
      model_hash.each do |k, v|
        k = k.to_s
        if (k == 'modelId')
          @model_id = v
        elsif (k == 'predictionDomain')
          @prediction_domain = v
        elsif (k == 'dataSourceName')
          @data_source_name = v
        elsif (k == 'createdDate')
          @created_date = DateTime.parse(v) unless v.nil?
        elsif (k == 'algorithm')
          @algorithm = NexosisApi::Algorithm.new(v) unless v.nil?
        elsif (k == 'columns')
          @column_metadata = v.reject { |_key, value| value.nil? }
                              .map do |col_key, col_val|
                                NexosisApi::Column.new(col_key, col_val)
                              end
        elsif (k == 'metrics')
          @metrics = v.reject { |_key, value| value.nil? }
                      .map do |col_key, col_val|
                        NexosisApi::Metric.new(name: col_key, value: col_val)
                      end
        end
      end
    end

    # Unique model id for this model in uuid/guid format.
    # @return [String]
    attr_accessor :model_id

    # The type of prediction performed
    # @return [String]
    attr_reader :prediction_domain

    # The data source used to create this model
    # @return [String]
    attr_accessor :data_source_name

    # The date on which this model was created.
    # @return [DateTime]
    attr_accessor :created_date

    # Information about the algorithm used to create the model
    # @return [NexosisApi::Algorithm]
    attr_accessor :algorithm

    # Descriptive information about the columns
    # @return [Array of NexosisApi::Column]
    attr_accessor :column_metadata

    # Algorithm and model specific metrics which may be of interest
    # @return [Array of NexosisApi::Metric]
    attr_accessor :metrics
  end
end