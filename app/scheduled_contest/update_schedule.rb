require 'cgi'
require 'open-uri'
require 'nokogiri'
require 'rexml/document'
require 'time'
require_relative '../operate_db.rb'

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
      if parsed_docs[0].text =~ /Recent/
        contest_data = []
      else
        links = parsed_docs[1].map.with_index { |cont, i| cont.text if i.odd? }
        links.compact!
        contest_data = links.map { |l| get_contest_data(BASE_URI + l) }
        contest_data.map!.with_index do |d, i| 
          d[:id] = i
          d
        end
      end
      @db = OperateDB.new(ScheduledContests, 'scheduled_contests')

      unless contest_data.eql?(@db.all_data)
        old = @db.all_data
        @db.reflesh_data(ScheduledContests, contest_data)
        puts('DB has been updated')
        return @db.get_all_data - old
      end
      return []
    end

    def get_page(url = BASE_URI)
      return Nokogiri::HTML.parse(URI.parse(url).open, nil, 'utf-8')
    end

    # xpaths must be array
    def parse_page(url, xpaths) 
      doc = get_page(url)
      ret = xpaths.map { |xp|
        doc.xpath(xp)
      }
      return ret
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

    #-------------------test funcs--------------------
    def get_page_test(file)
      return Nokogiri::HTML.parse(File.open(file), nil, 'utf-8')
    end

    def parse_page_test(file, xpaths) # xpaths must be array
      doc = get_page_test(file)
      xpaths = [
        '//title',
        '//script[9]'
      ]
      ret = xpaths.map { |xp|
        doc.xpath(xp).text
      }
      return ret
    end

    def main_page_test
      parsed_docs = parse_page_test('test.html', ["//div[@class= 'table-responsive'][3]//@href"])
      @links = parsed_docs[0].map.with_index { |cont, i| cont.text if i.odd? }
      @links.compact!
      contest_data = @links.map { |l|
        parse_page(l, xpaths)
      }
    end
  end
end
# obj = ScheduledContest::ScheduledContest.new
# obj.update
