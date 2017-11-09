module NexosisApi
  # Generic list base class for list responses
  # @since 1.4.0
  class PagedArray < Array
    def initialize(paged_response, item_array = [])
      self[0..item_array.length] = item_array
      var_map = { 'pageNumber' => :@page_number,
                  'totalPages' => :@total_pages,
                  'pageSize' => :@page_size,
                  'totalCount' => :@item_total }
      paged_response.each { |k, v| instance_variable_set(var_map[k.to_s], v) unless var_map[k.to_s].nil? }
      @links = paged_response['links'].map { |l| NexosisApi::Link.new(l) } unless paged_response['links'].nil?
    end

    # The current page number represented by this collection
    # @return [int]
    attr_accessor :page_number

    # The total number of pages given the current page size and item total
    # @return [int]
    attr_accessor :total_pages

    # The total number of items per page
    # @return [int]
    attr_accessor :page_size

    # The total number of items available on the server for this collection
    # @return [int]
    attr_accessor :item_total

    # paging links to first, last pages
    # @return [Array of NexosisApi::Link]
    attr_accessor :links
  end
end
