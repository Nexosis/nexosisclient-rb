require 'nexosis_api/session'

module NexosisApi
  # Class to parse the results from a new session
  class SessionResponse < Session
    def initialize(forecast_hash)
      val_map = {
        'Nexosis-Account-DataSetCount-Allotted' => :@datasets_allotted,
        'Nexosis-Account-DataSetCount-Current' => :@datasets_current,
        'Nexosis-Account-PredictionCount-Allotted' => :@predictions_allotted,
        'Nexosis-Account-PredictionCount-Current' => :@predictions_current,
        'Nexosis-Account-SessionCount-Allotted' => :@sessions_allotted,
        'Nexosis-Account-SessionCount-Current' => :@sessions_current
      }
      forecast_hash.each do |k, v|
        if (k == 'session')
          super(v) unless v.nil?
        else
          instance_variable_set(val_map[k], v) unless val_map[k].nil?
        end
      end
    end

    attr_reader :datasets_allotted
    attr_reader :datasets_allotted
    attr_reader :datasets_current
    attr_reader :predictions_allotted
    attr_reader :predictions_current
    attr_reader :sessions_allotted
    attr_reader :sessions_current
    
  end
end
