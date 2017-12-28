module NexosisApi
  # Constants for column data type
  module ColumnType
    # contains string data
    STRING = :string

    # contains numeric data
    NUMERIC = :numeric

    # contains boolean logical data (i.e. 1 and 0, true and false, etc.)
    LOGICAL = :logical

    # contains ISO-8601 compatible date 
    DATE = :date

    # Indicates a number which is not countable, or is not 'ordinal scaled' but 'ratio' or 'interval' scaled - i.e. a device measurement  
    NUMERICMEASURE = :numericmeasure

    # free-form text field.
    # @note differs from string primarily in how the data will be prepared for analysis. Nominal values belong in string. Text to be analyzed as speech, writing, etc. belongs in text field.
    TEXT = :text
  end
end
