# frozen_string_literal: true

module NexosisApi
  # class to hold the parsed result of a join
  class Join
    def initialize(join_hash)
      join_hash.each do |k, v|
        if k == 'dataSetName'
          @dataset_name = v unless v.nil?
        elsif k == 'columns'
          @columns = v unless v.nil?
        elsif k == 'joins'
          joins = []
          v.each do |join|
            joins << NexosisApi::Join.new(join)
            @joins = joins
          end
        end
      end
    end

    attr_accessor :dataset_name

    attr_accessor :columns

    attr_accessor :joins
  end
end
