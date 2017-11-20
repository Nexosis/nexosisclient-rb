require 'nexosis_api/session'
module NexosisApi
  # class to hold parsed results of confusion matrix request
  # @since 1.4.1
  class ClassifierResult < Session
    def initialize(classify_result)
      classify_result.each do |k, v|
        if (k.to_s == 'confusionMatrix')
          @confusion_matrix = v
        elsif (k.to_s == 'classes')
          @classes = v
        end
      end
      super(classify_result)
    end

    # array of arrays to form confusion matrix results
    # @return [Array of Array of Int] - the class counts for expected to predicted
    attr_accessor :confusion_matrix

    # Class labels in index order of matrix arrays
    # @return [Array]
    attr_accessor :classes
  end
end
