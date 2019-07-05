require 'cgi'
require 'open-uri'
require 'nokogiri'
require 'rexml/document'
require 'time'
require_relative '../operate_db.rb'
require_relative './scheduled_contest_db.rb'
require_relative './contest_data.rb'

module ScheduledContest
  class ScheduledContest
    BASE_URI = 'https://atcoder.jp'

    def update
      topxpath = ['//h4[2]', "//div[@class= 'table-responsive'][2]//@href"]
      parsed_docs = parse_page(BASE_URI, topxpath)
      p parsed_docs[0].text
      # table number of contests
      # 1... Permanent
      # 2... Upcoming
      # 3... Recent
      contest_data = []
      unless parsed_docs[0].text =~ /Recent|Constant/
        links = parsed_docs[1].map.with_index { |cont, i| cont.text if i.odd? }
        links.compact!
        contest_data = links.map do |l|
          get_contest_data(BASE_URI + l)
        end
      end
      return update_db contest_data
    end

    def update_db(contest_data)
      newd = ContestData.new(contest_data)
      @db = OperateDB.new
      old = ContestData.new(@db.all_data)
      return [] if newd.data.eql?(old.data)
      @db.reflesh_data(ScheduledContests, newd.with_index)
      puts('DB has been updated')
      return ContestData.new(@db.get_all_data).data - old
    end

    def get_page(url = BASE_URI)
      return Nokogiri::HTML.parse(URI.parse(url).open, nil, 'utf-8')
    end

    # xpaths must be array
    def parse_page(url, xpaths)
      doc = get_page(url)
      return xpaths.map { |xp|
        doc.xpath(xp)
      }
    end

    def format_contest_data(data)
      ret = {}
      ret[:title] = data[0].text
      times = data[1].text.scan(/\d{4}-\d{2}-\d{2}T\d{2}\:\d{2}\:\d{2}\+\d{2}\:\d{2}/)
      times.map! { |t| t.gsub!('T', "\s").gsub!('+', "\s+") }
      ret[:start_time] = Time.parse(times[0])
      ret[:end_time] = Time.parse(times[1])
      ret[:start_date] = ret[:start_time].to_date
      ret[:end_date] = ret[:end_time].to_date
      return ret
    end

    def get_contest_data(url)
      xpaths = [
        '//title',
        '//script[9]'
      ]
      raw_data = parse_page(url, xpaths)
      data = format_contest_data(raw_data)
      data[:url] = url
      return data
    end
  end
end
