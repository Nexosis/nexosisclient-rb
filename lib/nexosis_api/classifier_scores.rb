require 'nexosis_api/session_response'
module NexosisApi
  # class to hold parsed results of classifier scores request
  # @since 2.1.0
  class ClassifierScores < SessionResponse
    def initialize(classify_scores)
      props = %w[data metrics classes]
      classify_scores.select { |k, _v| props.include? k }.each { |k, v| instance_variable_set("@#{k}", v) }
      @data = NexosisApi::PagedArray.new(classify_scores, classify_scores['data'])
      super(classify_scores.reject { |k, _v| props.include? k })
    end

    # array of hashes with each class and its scored result
    # @return [NexosisApi::PagedArray] - the class result along with scores for each candidate class
    # @note the hash takes the form {"target": "class2", "target:class1": "3.21545", "target:class2":"4.2654", "feature1": "value", "target:actual": "class2"}
    attr_reader :data

    # Class labels represented in the data
    # @return [Array]
    attr_reader :classes

    # metrics of the classification model building session
    # @return [Hash] name value pairs of metrics
    attr_reader :metrics
  end
end
