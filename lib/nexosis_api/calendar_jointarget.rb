module NexosisApi
  # Specifies the details of a calendar data source to join to
  class CalendarJoinTarget
    def initialize(cal_join_hash)
      @url = cal_join_hash['url'] unless cal_join_hash.nil?
      @name = cal_join_hash['name'] unless cal_join_hash.nil?
    end

    # The location of a public iCal to download as the datasource
    # @return [String]
    attr_accessor :url

    # The name of a well-known Nexosis calendar.
    # @return [String]
    # see https://docs.nexosis.com
    attr_accessor :name

    def to_hash
      hash = { 'calendar' => {} }
      hash['calendar'].store 'url', url unless url.nil?
      hash['calendar'].store 'name', name unless name.nil?
      hash
    end
  end
end
