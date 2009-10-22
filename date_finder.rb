require 'rubygems'
require 'activesupport'

WorkPeriodStruct = Struct.new(:start,:end,:user,:task,:comment)

relative_path = "./output/"

parsed_data = []
date_strings = []
dates = []

Dir.new(relative_path).each do |fname|
  next if fname =~ /^\..*/ #== "." or fname == ".."
  print "Processing file '"+fname+"'..\n"
  initials = fname.split('-')[0].strip
  print "File is for user: '" + initials + "'\n"
  File.new(relative_path+fname).each_line do |line|
      parts = line.split(',')
      #skip lines until we find [date, "WEEK COMMENCING - ", ...] 
      next unless parts[0]
      matchdata = parts[0].match(/"WEEK COMMENCING/)
      d = nil
      if matchdata
        date_strings << parts
        if parts[0].match(/"WEEK COMMENCING - (\d\d.\d\d.\d\d)"/)
          mdata = parts[0].match(/"WEEK COMMENCING - (\d\d.\d\d.\d\d)"/)
          d = Date.strptime(mdata[1], '%d.%m.%y')
        elsif parts[0].match(/"WEEK COMMENCING - (\d\d.\d\d.\d\d\d\d)"/)
          mdata = parts[0].match(/"WEEK COMMENCING - (\d\d.\d\d.\d\d\d\d)"/)
          d = Date.strptime(mdata[1], '%d.%m.%Y')
        elsif parts[2].match(/(\d\d\d\d-\d\d-\d\d)/)
          mdata = parts[2].match(/(\d\d\d\d-\d\d-\d\d)/)
          d = Date.strptime(mdata[1], '%Y-%m-%d')
        else
          p line
          raise "Bad date!"
        end
        if d.wday != 1
          print "did not have a monday: " + d.to_s + " (wday is " + d.wday.to_s + ")\n"
        end
        dates << d
      end
  end
end

dates.uniq!.sort!
p dates[0]
p dates.last

date_strings.uniq.each do |x|
  p x
end
