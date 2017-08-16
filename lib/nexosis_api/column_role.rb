module NexosisApi
  # Constants for dataset column role
  module ColumnRole
    # No specific role, additional data which could be identified as target in a session
    NONE = :none

    # The timestamp column to use as the basis for a time-series session request
    TIMESTAMP = :timestamp

    # The target column for which to make predictions
    TARGET = :target

    # A feature to be included in analysis
    FEATURE = :feature
  end
end