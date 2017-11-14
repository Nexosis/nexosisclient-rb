module NexosisApi
  # class to provide message responses
  # @since 1.4.1
  class Message
    def initialize(message_hash)
      message_hash.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    # The type of message: information, warning, or error
    # @return [String]
    attr_accessor :severity

    # The content of the message
    # @return [String]
    attr_accessor :message
  end
end
