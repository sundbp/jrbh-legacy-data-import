require 'rubygems'

WorkPeriodStruct = Struct.new(:start,:end,:user,:task,:comment)

relative_path = "./output/"

parsed_data = []

Dir.new(relative_path).each do |fname|
  next if fname =~ /^\..*/ #== "." or fname == ".."
  print "Processing file '"+fname+"'..\n"
  initials = fname.split('-')[0].strip
  print "File is for user: '" + initials + "'\n"

  found_week_start = false
  skip_1 = 2
  skip_2 = 1
  has_dates = false
  dates = []
  starts = []
  ends = []
  tasks = [] 
  comments = []
  File.new(relative_path+fname).each_line do |line|
    parts = line.split(',')
    if found_week_start 
      unless has_dates
        if skip_1 > 0
          skip_1 = skip_1 - 1
          next
        end
        # process dates
        (2..20).step(3) do |d|
          dates << Date.strptime(parts[d], '%Y-%m-%d')
        end
        has_dates = true
      else
        if skip_2 > 0
          skip_2 = skip_2 - 1
          next
        end
      
        # check if no more entrie
        if parts[1] == ""
          found_week_start = false
          skip_1 = 2
          skip_2 = 1
          has_dates = false
          dates = []
          next
        end

        # parse start-end
        matchdata = parts[1].match(/(.*)-(.*)/) 
        raise "bad match: "+parts[1] unless matchdata != nil and matchdata.size == 3
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
          starts << Time.local(d.year,d.month,d.day,start_hour, start_min)
          ends << Time.local(d.year,d.month,d.day,end_hour, end_min)
        end
        
        #p parts[1]
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
          if start_t > Time.now or ends[i] > Time.now
            p start_t.to_s
            raise "Bad date!"
          end
          parsed_data << WorkPeriodStruct.new(start_t,ends[i],initials,tasks[i].strip,comments[i].strip)
        end

        starts = []
        ends = []
        tasks = []
        comments = []
      end
    else
      #skip lines until we find [date, "WEEK COMMENCING - ", ...] 
      if parts[1] == '"WEEK COMMENCING - "'
        found_week_start = true
      end
    end
  end
end

task_map = Hash[
  "(C) P3 Universal" => "C-P3 Universal",
  "P3 Universal" => "C-P3 Universal",
  "admin" => "Admin",
  "internal" => "Internal",
  "break" => "Break",
  "worklog" => "Worklog",
  "JRBH review" => "JRBH Review"
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
#  p x
end

comments = parsed_data.map {|x| x.comment}
comments.uniq!.sort!
#p "comments"
comments.each do |x|
#  print x.to_s + "\n"
end

File.open('worklog2.dump', "w+" ) do |f|
  Marshal.dump(parsed_data, f)
end
