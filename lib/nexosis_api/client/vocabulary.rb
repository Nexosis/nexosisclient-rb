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
      # @param page_size [Integer] the size of each page of paged results. Defaults to 50.
      # @return [NexosisApi::PagedArray of NexosisApi::VocabularySummary] - all vocabularies available within the query parameters
      # @raise [NexosisApi::HttpException]
      def list_vocabularies(datasource_name = nil, created_from_session=nil, page = 0, page_size = 50)
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

      # Gets a list of Vocabulary Words from a vocabulary
      # @param vocabulary_id [String] required unique identifier for vocabulary to get
      # @param type [String] whether to return 'word' types (default), 'stopWord' for only stop words, or nil for both.
      # @param page [Integer] the page number for paged results. Defaults to 0.
      # @param page_size [Integer] the size of each page of paged results. Defaults to 50.
      # @return [NexosisApi::PagedArray of NexosisApi::VocabularyWord]
      # @note words will be sorted in rank order
      # @raise [NexosisApi::HttpException]
      def get_vocabulary(vocabulary_id, type = 'word', page = 0, page_size = 50)
        raise ArgumentError, 'vocabulary_id was not provided and is not optional' if vocabulary_id.nil?
        vocab_url = "/vocabulary/#{vocabulary_id}"
        query = {
          page: page,
          pageSize: page_size
        }
        query.store('type', type) unless type.nil?
        response = self.class.get(vocab_url, headers: @headers, query: query)
        raise HttpException.new("There was a problem getting a vocabulary: #{response.code}.",
                                "getting vocabulary #{vocabulary_id}",
                                response) unless response.success?
        NexosisApi::PagedArray.new(response.parsed_response,
                                   response.parsed_response['items']
                                   .map { |item| NexosisApi::VocabularyWord.new(item) })
      end
    end
  end
end
