module ScheduledContest
  class ContestData
    attr_accessor :data
    def initialize(data_hash_list)
      @data = data_hash_list
      @data.each { |h| h.delete(:id) }
    end

    def with_index
      return @data.map.with_index { |d, i|
        d[:id] = i
        d
      }
    end
  end
end
