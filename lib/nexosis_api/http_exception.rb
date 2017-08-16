module NexosisApi
  # encapsulate errors from the Nexosis API
  class HttpException < StandardError
    attr_reader :message,:action,:response,:request
    def initialize(message = "", action = nil, http_obj)
      base_message = message
      full_message = nil
      if(http_obj.is_a?(Hash))
        base_message.prepend(http_obj['message'].concat(': ')) unless http_obj['message'].nil?
        @action = action
      elsif(http_obj.instance_of?(HTTParty::Response))
        full_message = base_message.concat('|| Explanation: ').concat(http_obj.parsed_response['errorDetails'].to_s) unless http_obj.parsed_response['errorDetails'].nil?
        @type = http_obj.parsed_response['errorType']
        @response = http_obj.response
        @request = http_obj.request
        @code = http_obj.code
      end
      full_message ||= base_message
      @message = full_message
    end

    attr_reader :code
    attr_reader :response
    attr_reader :request
    attr_reader :message
    attr_reader :type
  end
end