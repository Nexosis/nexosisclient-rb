module NexosisApi
  # Generic list base class for list responses
  # @since 1.4
  class PagedArray < Array
    def initialize(paged_response, item_array = [])
      self[0..item_array.length] = item_array
      paged_response.each do |k, v|
        key = k.to_s
        if key == 'pageNumber'
          @page_number = v
        elsif key == 'totalPages'
          @total_pages = v
        elsif key == 'pageSize'
          @page_size = v
        elsif key == 'totalCount'
          @item_total = v
        elsif key == 'links'
          @links = v.map { |l| NexosisApi::Link.new(l) }
        end
      end
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
