module NexosisApi
  # Class to hold the parsed response of a prediction request
  # @since 1.3.0
  class PredictResponse
    def initialize(model_id, response_hash)
      @model_id = model_id
      @predictions = response_hash['data']
      @message = response_hash['messages']
    end

    # The unique identifier for the model used to create these predictions
    # @return [String]
    attr_reader :model_id

    # The feature data along with predicted target value
    # @return [Array of Hash] each row of data as a hash in an array of values
    # @note The result data includes an echo of the data sent to the predict request
    # along with the target column containing the values predicted.
    # [
    #   {
    #     "feature1": 23.33,
    #     "target": 2.59
    #   },
    #   {
    #     "feature1": 15.82,
    #     "target": 1.75
    #   }
    # ]
    attr_accessor :predictions

    # A list of warning message optionally returned from prediction run
    # @return [Array]
    attr_accessor :messages
  end
end
