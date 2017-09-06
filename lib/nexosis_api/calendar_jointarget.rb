module NexosisApi
  # Specifies the details of a calendar data source to join to
  # @see http://docs.nexosis.com/guides/calendars
  # @since 1.2.3
  class CalendarJoinTarget
    def initialize(cal_join_hash)
      @url = cal_join_hash['url'] unless cal_join_hash.nil?
      @name = cal_join_hash['name'] unless cal_join_hash.nil?
      @timezone = cal_join_hash['timeZone'] unless cal_join_hash.nil?
    end

    # The location of a public iCal to download as the datasource
    # @return [String]
    attr_accessor :url

    # The name of a well-known Nexosis calendar.
    # @return [String]
    # @see http://docs.nexosis.com/guides/datasources
    attr_accessor :name

    # tz-db string name of the timezone of the calendar
    # @return [String]
    # @see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
    attr_accessor :timezone

    def to_hash
      hash = { 'calendar' => {} }
      hash['calendar'].store 'url', url unless url.nil?
      hash['calendar'].store 'name', name unless name.nil?
      hash['calendar'].store 'timeZone', name unless timezone.nil?
      hash
    end
  end
end
