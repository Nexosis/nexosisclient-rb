module NexosisApi
  # constants for the date/time interval (e.g. Day, Hour) at which predictions should be generated. 
  module TimeInterval
    # results summarized by hour
    HOUR = :hour
    # results summarized by day. Default option.
    DAY = :day
    # results summarized by week
    WEEK = :week
    # results summarized by month
    MONTH = :month
    # results summarized by year
    YEAR = :year
  end
end
