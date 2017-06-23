require 'nexosis_api/session'

module NexosisApi
    #Class to parse the results from a new session
    class SessionResponse < Session
        def initialize(forecast_hash)
            forecast_hash.each do |k,v|
				if(k == "session")
					super(v) unless v.nil?
				elsif(k == "nexosis-request-cost")
					instance_variable_set("@cost", v[0]) unless v.nil?
                elsif(k == "nexosis-account-balance")
                    instance_variable_set("@account_balance", v[0]) unless v.nil?
				end
			end
        end

        # The cost of this session with currency identifier
        # @return [String]
        attr_accessor :cost

        # Remaining balance after charge for this session
        # @return [String]
        attr_accessor :account_balance
    end
end