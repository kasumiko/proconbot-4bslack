require 'time'

class ContestInfo
  attr_accessor :info

  def initialize(contest_data)
      @info = contest_data.map{|contest|
      contest[:duration] = (contest[:end_time].to_i-contest[:start_time].to_i)/60
      start = contest[:start_time].strftime("%a %b %d %H:%M")
      text = "#{contest[:title]} #{start}~ コンテスト時間#{contest[:duration]}分\n"
      contest[:text] = text
      contest
    }
  end
end
