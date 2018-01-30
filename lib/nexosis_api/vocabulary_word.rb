module NexosisApi
  # parse results of a single word entry in a vocabulary
  # @since 2.2.0
  class VocabularyWord
    def initialize(word_hash)
      word_hash.each { |k, v| instance_variable_set("@#{k}", v) }
    end

    # The actual word or word pair
    # @return [String]
    attr_reader :text

    # Either word or stopWord
    # @return [String]
    attr_reader :type

    # For words the rank or relative importance of the word in predictions. Nil for stop words.
    # @return [Integer]
    attr_reader :rank

  end
end
