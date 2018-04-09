module NexosisApi
  # Class to hold general query options for list requests
  # @since 3.0.0
  class ListQuery
    def initialize(options = { 'page_number': 0, 'page_size': 50 })
      @page_number = options.key?(:page_number) ? options[:page_number] : 0
      @page_size = options.key?(:page_size) ? options[:page_size] : 50
      @sort_order = NexosisApi::SortOrder.const_get(options[:sort_order].upcase) if options.key? :sort_order
      @sort_by = options[:sort_by] if options.key? :sort_by
    end

    def to_hash
      query = {
        'page': @page_number,
        'pageSize': @page_size
      }
      query.store(:sortOrder, @sort_order) unless @sort_order.nil?
      query.store(:sortBy, @sort_by) unless @sort_by.nil?
      query
    end

    # Count of results to retrieve in each page (max 1000).
    # @return [Integer]
    attr_accessor :page_size

    # zero-based page number of results to retrieve
    # @return [Integer]
    attr_accessor :page_number

    # Direction to sort the results.
    # @return [NexosisApi::SortOrder]
    attr_accessor :sort_order

    # The name of an entity property to sort by
    # @return [String]
    # @note - each entity has different possibilities. See the api doc links on each list type for more information.
    attr_accessor :sort_by
  end

  # class to hold the query options for list datasets
  # @since 3.0.0
  # @see https://developers.nexosis.com/docs/services/98847a3fbbe64f73aa959d3cededb3af/operations/datasets-list-all?
  # @note - sort by properties include dataSetName, dataSetSize, rowCount, dateCreated, and lastModified
  class DatasetListQuery < ListQuery
    def initialize(options = {})
      @partial_name = options[:partial_name] if options.key? :partial_name
      super(options)
    end

    # A hash suitable for using as the query portion of an HTTP request to the API
    # @return [Hash]
    def query_parameters
      parm_hash = {}
      parm_hash.store(:partialName, @partial_name) unless @partial_name.nil?
      self.to_hash.merge(parm_hash)
    end
    # The name or part of a name by which to limit the list results.
    # @return [String]
    attr_accessor :partial_name
  end

  # class to hold the query options for list datasets
  # @since 3.0.0
  # @see https://developers.nexosis.com/docs/services/98847a3fbbe64f73aa959d3cededb3af/operations/sessions-list-all?
  # @note sort by properties include id, name, type, status, dataSourceName, and requestedDate
  class SessionListQuery < ListQuery
    def initialize(options = {})
      @datasource_name = options[:datasource_name] if options.key? :datasource_name
      @event_name = options[:event_name] if options.key? :event_name
      @model_id = options[:model_id] if options.key? :model_id
      @requested_after_date = options[:requested_after_date] if options.key? :requested_after_date
      @requested_before_date = options[:requested_before_date] if options.key? :requested_before_date
      super(options)
    end

    # A hash suitable for using as the query portion of an HTTP request to the API
    # @return [Hash]
    def query_parameters
      parm_hash = {}
      parm_hash.store(:dataSourceName, @datasource_name) unless @datasource_name.nil?
      parm_hash.store(:eventName, @event_name) unless @event_name.nil?
      parm_hash.store(:modelId, @model_id) unless @model_id.nil?
      parm_hash.store(:requestedAfterDate, @requested_after_date) unless @requested_after_date.nil?
      parm_hash.store(:requestedBeforeDate, @requested_before_date) unless @requested_before_date.nil?
      self.to_hash.merge(parm_hash)
    end

    # Limits sessions to those for a particular data source
    # @return [String]
    attr_accessor :datasource_name

    # Limits impact sessions to those for a particular event
    # @return [String]
    attr_accessor :event_name

    # Limits model-building sessions to those that built the specified model
    # @return [String]
    attr_accessor :model_id

    # Format - date-time (as date-time in ISO8601). Limits sessions to those requested on or after the specified date
    # @return [String]
    attr_accessor :requested_after_date

    # Format - date-time (as date-time in ISO8601). Limits sessions to those requested on or before the specified date
    # @return [String]
    attr_accessor :requested_before_date
  end

  # class to hold the query options for list models
  # @since 3.0.0
  # @see https://developers.nexosis.com/docs/services/98847a3fbbe64f73aa959d3cededb3af/operations/models-list-all?
  # @note sort by properties include id, modelName, dataSourceName, type, createdDate, and lastUsedDate
  class ModelListQuery < ListQuery
    def initialize(options = {})
      @datasource_name = options[:datasource_name] if options.key? :datasource_name
      @created_after_date = options[:created_after_date] if options.key? :created_after_date
      @created_before_date = options[:created_before_date] if options.key? :created_before_date
      super(options)
    end

    # A hash suitable for using as the query portion of an HTTP request to the API
    # @return [Hash]
    def query_parameters
      parm_hash = {}
      parm_hash.store(:dataSourceName, @datasource_name) unless @datasource_name.nil?
      parm_hash.store(:createdAfterDate, @created_after_date) unless @created_after_date.nil?
      parm_hash.store(:createdBeforeDate, @created_before_date) unless @created_before_date.nil?
      self.to_hash.merge(parm_hash)
    end

    # Limits models to those for a particular data source
    # @return [String]
    attr_accessor :datasource_name

    # Format - date-time (as date-time in ISO8601). Limits models to those created on or after the specified date
    # @return [String]
    attr_accessor :created_after_date

    # Format - date-time (as date-time in ISO8601). Limits models to those created on or before the specified date
    # @return [String]
    attr_accessor :created_before_date
  end

  # class to hold the query options for list imports
  # @since 3.0.0
  # @see https://developers.nexosis.com/docs/services/98847a3fbbe64f73aa959d3cededb3af/operations/imports-list-imports?
  # @note sort by properties include id, dataSetName, requestedDate, and currentStatusDate
  class ImportListQuery < ListQuery
    def initialize(options = {})
      @dataset_name = options[:dataset_name] if options.key? :dataset_name
      @requested_after_date = options[:requested_after_date] if options.key? :requested_after_date
      @requested_before_date = options[:requested_before_date] if options.key? :requested_before_date
      super(options)
    end

    # A hash suitable for using as the query portion of an HTTP request to the API
    # @return [Hash]
    def query_parameters
      parm_hash = {}
      parm_hash.store(:dataSourceName, @dataset_name) unless @dataset_name.nil?
      parm_hash.store(:requestedAfterDate, @requested_after_date) unless @requested_after_date.nil?
      parm_hash.store(:requestedBeforeDate, @requested_before_date) unless @requested_before_date.nil?
      self.to_hash.merge(parm_hash)
    end

    # Limits imports to those for a particular dataset
    # @return [String]
    attr_accessor :dataset_name

    # Format - date-time (as date-time in ISO8601). Limits imports to those requested on or after the specified date
    # @return [String]
    attr_accessor :requested_after_date

    # Format - date-time (as date-time in ISO8601). Limits imports to those requested on or before the specified date
    # @return [String]
    attr_accessor :requested_before_date
  end
end
