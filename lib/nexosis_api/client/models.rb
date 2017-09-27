module NexosisApi
  class Client
    # class to operate on model endpoint in Nexosis API
    # @since 1.3.0
    module Models
      # List all models created in your company, optionally filtered by query parameters
      #
      # @param data_source_name [String] optionally limit to those
      # models created for this data source name.
      # @param query_options [Hash] limit by dates: createdAfterDate and/or createdBeforeDate
      # @note - query options dates can either be ISO 8601 compliant strings or Date objects
      # @return [NexosisApi::] - all models available within the query parameters
      def list_models(data_source_name = nil, page = 0, page_size = 50, query_options={})
        model_url = '/models'
        query = {
          page: page,
          pageSize: page_size
        }
        query = query.merge(query_options)
        query.store(dataSourceName: data_source_name) unless data_source_name.nil?
        response = self.class.get(model_url, headers: @headers, query: query)
        if (response.success?)
          response.parsed_response['items'].map { |item| NexosisApi::ModelSummary.new(item) }
        else
          raise HttpException.new("There was a problem listing models: #{response.code}.", "listing models with data source name #{data_source_name}", response)
        end
      end
    end
  end
end
