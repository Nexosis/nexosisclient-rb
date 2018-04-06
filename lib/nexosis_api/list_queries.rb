module NexosisApi
  # Class to hold general query options for list requests
  # @since 3.0.0
  class ListQuery
    def initialize(options = { 'page_number': 0, 'page_size': 50 })
      @page_number = options[:page_number] if options.key? :page_number
      @page_size = options[:page_size] if options.key? :page_size
      @sort_order = NexosisApi::SortOrder.const_get(options[:sort_order]) if options.key? :sort_order
      @sort_by = options[:sort_by] if options.key? :sort_by
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
    def initialize(options)
      super(options)
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
    def initialize(options)
      @datasource_name = options[:datasource_name] if options.key? :datasource_name
      @event_name = options[:event_name] if options.key? :event_name
      @model_id = options[:model_id] if options.key? :model_id
      @requested_after_date = options[:requested_after_date] if options.key? :requested_after_date
      @requested_before_date = options[:requested_before_date] if options.key? :requested_before_date
      super(options)
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
    def initialize(options)
      @datasource_name = options[:datasource_name] if options.key? :datasource_name
      @created_after_date = options[:created_after_date] if options.key? :created_after_date
      @created_before_date = options[:created_before_date] if options.key? :created_before_date
      super(options)
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
    def initialize(options)
      @dataset_name = options[:dataset_name] if options.key? :dataset_name
      @requested_after_date = options[:requested_after_date] if options.key? :requested_after_date
      @requested_before_date = options[:requested_before_date] if options.key? :requested_before_date
      super(options)
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
