module NexosisApi
  # parsed results of a request for vocabulary
  # @since 2.2.0
  class VocabularySummary
    def initialize(vocab_hash)
      var_map = { 'id' => :@vocabulary_id,
                  'dataSourceName' => :@datasource_name,
                  'columnName' => :@column_name,
                  'dataSourceType' => :@datasource_type,
                  'createdOnDate' => :@created_on,
                  'createdBySessionId' => :@created_by_session }
      vocab_hash.each { |k, v| instance_variable_set(var_map[k.to_s], v) unless var_map[k.to_s].nil? }
      @links = vocab_hash['links'].reject(&:nil?).map { |l| NexosisApi::Link.new(l) }
    end

    # unique identifier for this vocabulary
    # @return [String]
    attr_reader :vocabulary_id

    # datasource which contained the text column the vocabulary was built from
    # @return [String]
    attr_reader :datasource_name

    # text-based column name from the datasource
    # @return [String]
    attr_reader :column_name

    # determines if data source was dataSet, View, or other
    # @return [String]
    attr_reader :datasource_type

    # The date on which the vocabulary was created
    # @return [DateTime]
    attr_reader :created_on

    # The unique id of the session for which this vocabulary was built.
    # @return [String]
    attr_reader :created_by_session

    # hypermedia related to this vocabulary
    # @return [Arrays]
    attr_reader :links
  end
end
