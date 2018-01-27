module NexosisApi
  # class to operate on vocabulary endpoint in Nexosis API
  class Client
    # Vocabluary-based API operations
    # @see http://docs.nexosis.com/
    # @since 2.2.0
    module Vocabulary
      # Gets summary information about the Vocabulary built from the Text columns in a session
      # @param datasource_name [String] optionally limit to those
      # vocabularies created for this data source name.
      # @param created_from_session [String] optionally limit to those
      # vocabularies created for the given session.
      # @param page [Integer] the page number for paged results. Defaults to 0.
      # @param page_size [Integer] the size of each page of paged results. Defaults to 30.
      # @return [NexosisApi::PagedArray of NexosisApi::VocabularySummary] - all vocabularies available within the query parameters
      # @raise [NexosisApi::HttpException]
      def list_vocabularies(datasource_name = nil, created_from_session=nil, page = 0, page_size = 30)
        vocab_url = '/vocabulary'
        query = {
          page: page,
          pageSize: page_size
        }
        query.store('created_from_session', datasource_name) unless created_from_session.nil?
        query.store('dataSourceName', datasource_name) unless datasource_name.nil?
        response = self.class.get(vocab_url, headers: @headers, query: query)
        raise HttpException.new("There was a problem listing vocabularies: #{response.code}.",
                                "listing vocabularies with data source name #{datasource_name}",
                                response) unless response.success?
        NexosisApi::PagedArray.new(response.parsed_response,
                                   response.parsed_response['items']
                                   .map { |item| NexosisApi::VocabularySummary.new(item) })
      end
    end
  end
end
