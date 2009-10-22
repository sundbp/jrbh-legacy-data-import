require 'rubygems'
require 'activesupport'

WorkPeriodStruct = Struct.new(:start,:end,:user,:task,:comment)

relative_path = "./output/"

parsed_data = []

date_strings = []
all_dates = []

Dir.new(relative_path).each do |fname|
  next if fname =~ /^\..*/ #== "." or fname == ".."
  print "Processing file '"+fname+"'..\n"
  initials = fname.split('-')[0].strip
  print "File is for user: '" + initials + "'\n"

  found_week_start = false
  start_date = nil
  skip_1 = 3
  dates = []
  starts = []
  ends = []
  tasks = [] 
  comments = []
  File.new(relative_path+fname).each_line do |line|
    parts = line.split(',')
    if found_week_start 
      if skip_1 > 0
        skip_1 = skip_1 - 1
        next
      end
      # check if no more entrie
      if parts[0] == ""
        found_week_start = false
        skip_1 = 3
        dates = []
        next
      end

      # parse start-end
      matchdata = parts[0].match(/(.*)-(.*)/) 
      raise "bad match: "+parts[0] unless matchdata != nil and matchdata.size == 3
      start_string = matchdata[1].sub('"', "")
      end_string = matchdata[2].sub('"', "")

      matchdata = start_string.match(/(.*)\.(.*)/)
      raise "bad match: "+start_string unless matchdata != nil and matchdata.size == 3
      start_hour = matchdata[1].to_i
      start_min = matchdata[2].to_i

      matchdata = end_string.match(/^(\d+).*(\d\d)$/)
      raise "bad match: "+end_string unless matchdata != nil and matchdata.size == 3
      end_hour = matchdata[1].to_i
      end_min = matchdata[2].to_i

      dates.each do |d|
        s = Time.local(d.year,d.month,d.day,start_hour, start_min)
        e = Time.local(d.year,d.month,d.day,end_hour, end_min)
        if s > Time.now or e > Time.now
          p d.year
          p start_hour
          p end_hour 
        end
        starts << s 
        ends << e
      end
       
      #p parts[0]
      #p "starts"
      #starts.each {|x| p x.to_s }
      #p "ends"
      #ends.each {|x| p x.to_s }
        
      # create a WorkPeriod object
      (1..parts.size-1).each do |d|
        if parts[d] == "0.5"
          tasks << parts[d-1].gsub('"', "")
          comment_parts = [];
          x = d-2;
          while parts[x] != "0.5" and not parts[x].match(/\d+.\d+-\d+.\d+/)
            comment_parts << parts[x].gsub('"', "")
            x = x-1
          end
          comments << comment_parts.reverse.join(" ")
        end
      end

      starts.each_with_index  do |start_t,i|
        next if tasks[i] == '. - - - - - -' or tasks[i] == "" or tasks[i] == nil
        parsed_data << WorkPeriodStruct.new(start_t,ends[i],initials,tasks[i].strip,comments[i].strip)
      end

      starts = []
      ends = []
      tasks = []
      comments = []
    else
      #skip lines until we find [date, "WEEK COMMENCING - ", ...] 
      next unless parts[0]
      matchdata = parts[0].match(/"WEEK COMMENCING/)
      d = nil
      if matchdata
        date_strings << parts
        if parts[0].match(/"WEEK COMMENCING - (\d\d.\d\d.\d\d)"/)
          mdata = parts[0].match(/"WEEK COMMENCING - (\d\d.\d\d.\d\d)"/)
          d = Date.strptime(mdata[1], '%d.%m.%y')
          all_dates << d 
        elsif parts[0].match(/"WEEK COMMENCING - (\d\d.\d\d.\d\d\d\d)"/)
          mdata = parts[0].match(/"WEEK COMMENCING - (\d\d.\d\d.\d\d\d\d)"/)
          d = Date.strptime(mdata[1], '%d.%m.%Y')
          all_dates << d 
        elsif parts[2].match(/(\d\d\d\d-\d\d-\d\d)/)
          mdata = parts[2].match(/(\d\d\d\d-\d\d-\d\d)/)
          d = Date.strptime(mdata[1], '%Y-%m-%d')
          all_dates << d 
        else
          p line
          raise "Bad date!"
        end
        s = -d.wday-1
        if s == -7
          s = 0
        end
        e = s + 6
        (s..e).each do |x|
          a = x.days.since(d)
          if a > Date.today
            p parts[0] 
            raise "Bad date!"
          end
          dates << a
        end
        found_week_start = true
      end
    end
  end
end

task_map = Hash[
  "lunch" => "Lunch",
  "internal" => "Internal",
  "Stanton CHase" => "Stanton Chase",
  "universal" => "Universal",
  "UNiversal" => "Universal",
  "admin" => "Admin",
  "JRBH review" => "JRBH Review",
  "P3 Universal" => "C-P3 Universal",
  "New Client" => "Educor 2"
]
parsed_data.each do |x|
  if task_map.has_key? x.task
    x.task = task_map[x.task]
  end
end

users = parsed_data.map {|x| x.user}
users.uniq!.sort!
#p "users"
users.each do |x|
#  print x.to_s + "\n"
end

tasks = parsed_data.map {|x| x.task}
tasks.uniq!.sort!
#p "tasks"
tasks.each do |x|
  #print x.to_s + "\n"
  #p x
end

comments = parsed_data.map {|x| x.comment}
comments.uniq!.sort!
#p "comments"
comments.each do |x|
#  print x.to_s + "\n"
end

#trim off overlapping data
tmp = []
parsed_data.each do |x|
  unless x.start > Time.local(2009, 7, 4)
    tmp << x
  else
    #print "Skipping data: \n"
    #p x
  end
end
parsed_data = tmp
File.open('worklog1.dump', "w+" ) do |f|
  Marshal.dump(parsed_data, f)
end

