require 'net/http'
require 'time'
require 'chronic'
require 'pp'
require 'moji'

module Ag
  class Program < Struct.new(:start_time, :minutes, :title)
  end

  class ProgramTime < Struct.new(:wday, :time)
    SAME_DAY_LINE_HOUR = 5

    # convert human friendly time to computer friendly time
    def self.parse(wday, time_str)
      time = Time.parse(time_str)
      if time.hour < SAME_DAY_LINE_HOUR
        wday = (wday + 1) % 7
      end
      self.new(wday, time)
    end

    def next_on_air
      time = chronic(wday_for_chronic_include_today(self[:wday]))
      if time > Time.now
        return time
      else
        chronic(wday_to_s(self[:wday]))
      end
    end

    def chronic(day_str)
      Chronic.parse(
        "#{day_str} #{self[:time].strftime("%H:%M")}",
        context: :future,
        ambiguous_time_range: :none,
        hours24: true,
        guess: :begin
      )
    end

    def wday_for_chronic_include_today(wday)
      if Time.now.wday == wday
        return 'today'
      end
      wday_to_s(wday)
    end

    def wday_to_s(wday)
      %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)[wday]
    end
  end

  class Scraping
    def main
      programs = scraping_page
      programs = validate_programs(programs)
      programs
    end

    def validate_programs(programs)
      if programs.size < 20
        puts "Error: Number of programs is too few!"
        exit
      end
      programs.delete_if do |program|
        program.title == '放送休止'
      end
    end


    def scraping_page
      html = Net::HTTP.get(URI.parse('http://www.agqr.jp/timetable/streaming.php'))
      dom = Nokogiri::HTML.parse(html)
      tbody = dom.css('.timetb-ag tbody') # may be 30minutes belt
      td_list_list = parse_broken_table(tbody)
      two_dim_array = table_to_two_dim_array(td_list_list)
      two_dim_array.inject([]) do |programs, belt|
        programs + parse_belt_dom(belt)
      end
    end

    def parse_broken_table(tbody)
      # time table HTML is broken!!!!!! some row aren't opened by <tr>.
      td_list_list = []
      td_list_tmp = []
      tbody.children.each do |tag|
        if tag.name == 'td'
          td_list_tmp.push tag
        elsif tag.name == 'tr' || tag.name == 'th'
          unless td_list_tmp.empty?
            td_list_list.push td_list_tmp
            td_list_tmp = []
          end
          if tag.name == 'tr'
            td_list_list.push tag.css('td')
          end
        end
      end
      unless td_list_tmp.empty?
        td_list_list.push td_list_tmp
      end
      td_list_list
    end

    def parse_belt_dom(belt)
      belt.each_with_index.inject([]) do |programs, (td, index)|
        next programs unless td
        wday = (index + 1) % 7 # monday start
        programs << parse_td_dom(td, wday)
      end
    end

    def table_to_two_dim_array(td_list_list)
      aa = []
      span = {}
      td_list_list.each_with_index do |td_list, row_n|
        a = []
        col_n = 0
        td_list.each do |td|
          while span[[row_n, col_n]]
            a.push(nil)
            col_n += 1
          end
          a.push(td)
          cspan = 1
          if td['colspan'] =~ /(\d+)/
            cspan = $1.to_i
          end
          rspan = 1
          if td['rowspan'] =~ /(\d+)/
            rspan = $1.to_i
          end
          (row_n...(row_n + rspan)).each do |r|
            (col_n...(col_n + cspan)).each do |c|
              span[[r, c]] = true
            end
          end
          col_n += 1
        end
        aa.push(a)
      end
      aa
    end

    def parse_td_dom(td, wday)
      start_time = parse_start_time(td, wday)
      minutes = parse_minutes(td)
      title = parse_title(td)
      if td['class'] !~ /bg-[fl]/ && title != '放送休止'
        title += " 再" # " \u{1F21E}"
      end
      Program.new(start_time, minutes, title)
    end

    def parse_minutes(td)
      rowspan = td.attribute('rowspan')
      if !rowspan || rowspan.value.blank?
        30
      else
        td.attribute('rowspan').value.to_i * 30
      end
    end

    def parse_start_time(td, wday)
      ProgramTime.parse(wday, td.css('.time')[0].text)
    end

    def parse_title(td)
      [td.css('.title-p')[0].text, td.css('.rp')[0].text].select do |text|
        !text.gsub(/\s/, '').empty?
      end.map do |text|
        Moji.normalize_zen_han(text).strip
      end.join(' ')
    end
  end
end
