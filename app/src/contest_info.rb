require 'time'

class ContestInfo
  attr_accessor :info

  def initialize(contest_data)
    @info = contest_data.map do |contest|
      start_time = contest[:start_time]
      end_time = contest[:end_time]
      duration = (end_time.to_i - start_time.to_i) / 60
      contest[:duration] = duration
      start = start_time.strftime('%a %b %d %H:%M')
      text = "#{contest[:title]}\n#{start}~ コンテスト時間#{duration}分\n"
      contest[:text] = text + contest[:url]
      contest
    end
  end
end
