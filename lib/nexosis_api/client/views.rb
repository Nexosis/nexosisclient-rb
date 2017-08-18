module NexosisApi
  # class to operate on views endpoint in Nexosis API
  class Client
    # Views-based API operations
    # @see http://docs.nexosis.com/
    # @since v1.2
    module Views
      ## List all existing view defintions, optionally limited by
      # partial name or participating data sources
      # @param partial_name [String] optionally limit results by view name
      # @param dataset_name [String] optionally limit results by dataset used in definition
      # @param page [Integer] optionally get results by non-zero page - defaults to 0
      # @param page_size [Integer] optionally limit page size - defaults to 50 (max: 1000)
      # @return [Array of NexosisApi::ViewDefinition]
      # @raise [NexosisApi::HttpException]
      def list_views(partial_name = '', dataset_name = '', page = 0, page_size = 50)
        url = '/views'
        query = {
          'page': page,
          'pageSize': page_size
        }
        query.store 'partialName', partial_name if partial_name.empty? == false
        query.store 'dataSetName', dataset_name if dataset_name.empty? == false
        response = self.class.get(url, headers: @headers, query: query)
        if response.success?
          items = []
          response.parsed_response['items'].each do |definition|
            items << NexosisApi::ViewDefinition.new(definition)
          end
          items
        end
      end

      # Create a new view or update an existing one by name
      # @param view_name [String] the name of the view to create or update.
      # @param dataset_name [String] the unique name of a data that is one source of this view.
      # @param right_datasource_name [String] the additional data source to join in this view.
      # @return [NexosisApi::ViewDefinition] - definition as created by API
      # @note @view_name Must be unique within your organization
      # @raise [NexosisApi::HttpException]
      def create_view(view_name, dataset_name, right_datasource_name)
        raise ArgumentError 'view_name was not provided and is not optional' unless view_name.to_s.empty? == false
        raise ArgumentError 'dataset_name was not provided and is not optional' unless dataset_name.to_s.empty? == false
        raise ArgumentError 'right_datasource_name was not provided and is not optional' unless right_datasource_name.to_s.empty? == false
        view_definition = NexosisApi::ViewDefinition.new('viewName' => view_name)
        view_definition.dataset_name = dataset_name
        join = NexosisApi::Join.new('dataSet' => { 'name' => right_datasource_name })
        view_definition.joins = [join]
        create_view_by_def(view_definition)
      end

      # Create or update a view based on a view definition object
      # @param view_definition [NexosisApi::ViewDefinition] an object populated with the view configuration to create
      # @return [NexosisApi::ViewDefinition] - definition as created by API
      # @raise [NexosisApi::HttpException]
      def create_view_by_def(view_definition)
        view_name = view_definition.view_name
        raise ArgumentError 'view_name was not provided and is not optional' unless view_name.to_s.empty? == false
        url = "/views/#{view_name}"
        response = self.class.put(url, headers: @headers, body: view_definition.to_json)
        if response.success?
          return NexosisApi::ViewDefinition.new(response.parsed_response)
        else
          raise NexosisApi::HttpException.new('Could not create the requested view',
                                              "Attempting to create view named #{view_name}",
                                              response)
        end
      end

      # Deletes the named view and optionally all sessions created from it
      # @param view_name [String] the view to remove
      # @param cascade [String] indicate any non-nil to remove associated sessions
      # @return [void]
      # @raise [NexosisApi::HttpException]
      def remove_view(view_name, cascade = nil)
        raise ArgumentError 'view_name was not provided and is not optional' unless view_name.to_s.empty? == false
        url = "/views/#{view_name}"
        query = 'cascade=sessions' unless cascade.nil?
        response = self.class.delete(url, headers: @headers, query: query)
        unless response.success?
          raise NexosisApi::HttpException.new('Could not delete view',
                                              "Attempting to delete view #{view_name}",
                                              response)
        end
      end

      # Get the processed data from the view definition
      #
      # @param view_name [String] the unique name of the view for which to retrieve data
      # @param page_number [Integer] zero-based page number of results to retrieve
      # @param page_size [Integer] Count of results to retrieve in each page (max 1000).
      # @param query_options [Hash] options hash for limiting and projecting returned results
      # @note Query Options includes start_date as a DateTime or ISO 8601 compliant string,
      #    end_date, also as a DateTime or string, and :include as an Array of strings indicating the columns to return.
      #    The dates can be used independently and are inclusive. Lack of options returns all values within the given page.
      # @note - the results include any transformations or imputations required to prepare the data for a session
      # @raise [NexosisApi::HttpException]
      def get_view(view_name, page_number = 0, page_size = 50, query_options = {})
        raise ArgumentError 'view_name was not provided and is not optional' unless view_name.to_s.empty? == false
        url = "/views/#{view_name}"
        response = self.class.get(url, headers: @headers,
                                       query: create_query(page_number, page_size, query_options),
                                       query_string_normalizer: ->(query_map) { array_query_normalizer(query_map) } )
        raise NexosisApi::HttpException.new('Could not retrieve data for the given view', "Requesting data for view #{view_name}", response) unless response.success?
        NexosisApi::ViewData.new(response.parsed_response)
      end
    end
  end
end
