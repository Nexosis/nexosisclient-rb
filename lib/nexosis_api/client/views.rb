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
        view_definition = NexosisApi::ViewDefinition.new('viewName' => view_name)
        view_definition.dataset_name = dataset_name
        join = NexosisApi::Join.new('dataSetName' => right_datasource_name)
        view_definition.joins = [join]
        create_view_by_def(view_definition)
      end

      # Create or update a view based on a view definition object
      # @param view_definition [NexosisApi::ViewDefinition] an object populated with the view configuration to create
      # @return [NexosisApi::ViewDefinition] - definition as created by API
      # @raise [NexosisApi::HttpException]
      def create_view_by_def(view_definition)
        view_name = view_definition.view_name
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
        url = "/views/#{view_name}"
        query = 'cascade=sessions' unless cascade.nil?
        response = self.class.delete(url, headers: @headers, query: query)
        raise NexosisApi::HttpException.new('Could not delete view',
                                            "Attempting to delete view #{view_name}",
                                            response) unless response.success?
      end
    end
  end
end
