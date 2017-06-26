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
    end
end