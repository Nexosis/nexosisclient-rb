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

    # This column will be used to uniquely identify rows during
    # update and delete operations, but will not be used as a feature.
    KEY = :key
  end
end