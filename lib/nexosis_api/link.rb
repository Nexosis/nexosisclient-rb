module NexosisApi
  # Class to parse hypermedia resutls
  class Link
    def initialize(link_hash)
      link_hash.each do |k, v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    # relation type of the link
    # @return [String]
    attr_accessor :rel

    # resource url
    # @return [String]
    attr_accessor :href
  end
end
