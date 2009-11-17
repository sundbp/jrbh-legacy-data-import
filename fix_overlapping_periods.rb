#!/usr/bin/env /Users/patrik/RubymineProjects/jrbh-worklog/script/runner -e production

def overlaps?(wp1, wp2)
  #p wp1.start
  #p wp2.end-1.minute
  #p wp1.end
  #p wp2.start+1.minute
  if wp1.nil? or wp2.nil?
    print "found a nil:\n"
    p wp1
    p wp2
  end

  if wp1["start"] > (wp2["end"]-1.minute) or wp1["end"] < (wp2["start"]+1.minute)
    false
  else
    if wp1["worklog_task_id"] == wp2["worklog_task_id"]
      true
    else
      false
    end
  end
end

def process_map(overlap_map)
  new_map = Hash.new
  overlap_map.each_key do |key|
    res = merge_map(overlap_map, key)
    #print "setting new value of #{key} to #{res}\n"
    new_map[key] = res
  end
  res = new_map.sort {|a, b| a[1].size <=> b[1].size}
  to_remove = []
  res = res.reverse.select do |x|
    if to_remove.include? x[0]
      false
    else
      to_remove.concat(x[1].select {|y| y != x[0]})
      true
    end
  end
  res
end

def merge_map(overlap_map, key)
  if not overlap_map.has_key? key
    print "Seems like this key is missing:\n"
    p key
    print "Overlap map:\n"
    overlap_map.each_key {|x| p x["id"]} 
  end
  if overlap_map[key].size == 0
    return [key]
  else
    res = overlap_map[key].map {|x| merge_map(overlap_map, x)}
    res << key
    res.flatten
  end
end

def merge_periods(periods)
  early_start = nil
  late_end = nil
  comments = []
  periods.each do |x|
    early_start = x["start"] if early_start.nil?
    late_end = x["end"] if late_end.nil?

    comments << x["comment"]
    early_start = x["start"] if x["start"] < early_start
    late_end = x["end"] if x["end"] > late_end
  end
  c = comments.flatten.uniq.join(",")
  {"start" => early_start, "end" => late_end,
   "worklog_task_id" => periods[0]["worklog_task_id"],
   "user_id" => periods[0]["user_id"],
   "comment" => c
  }
end

USER = "JO"
COMMIT = false 

User.find(:all).each do |u|
  next unless u.alias == USER
  print "Searching for matches for user #{u.alias}\n"
  wps = WorkPeriod.find(:all, :conditions => ["user_id = ?", u.id])

  print "Have #{wps.size} periods to compare\n"

  overlaps = []
  (0..wps.size-1).each do |i|
    next if i == wps.size-1
    (i+1..wps.size-1).each do |j|
      wp1 = wps[i]
      wp2 = wps[j]
      next if wp1 == wp2
      if overlaps?(wp1,wp2)

        raise "not same task" if wp1.worklog_task != wp2.worklog_task
        #  print "Weird, overlap but not same task!\t"
        #  print "(#{wp1.start}-#{wp1.end}, #{wp1.worklog_task.name}) and (#{wp2.start}-#{wp2.end}, #{wp2.worklog_task.name}) (#{wp1.id}, #{wp2.id})\n"
        #  next
        #end

        overlaps << wp1
        overlaps << wp2

        print "(#{wp1.start}-#{wp1.end}, #{wp1.worklog_task.name}) and (#{wp2.start}-#{wp2.end}, #{wp2.worklog_task.name}) (#{wp1.id}, #{wp2.id})\t"
        early_start = wp1.start <= wp2.start ? wp1.start : wp2.start
        late_end = wp1.end >= wp2.end ? wp1.end : wp2.end
        long_comment = wp1.comment.to_s + wp2.comment.to_s
        print "Union: (#{early_start}-#{late_end})\n"
      end
    end
  end
  
  print "Attempting to condense overlaps..\n"
  result = overlaps.map {|x| x.attributes}
  no_overlaps = false 
  until no_overlaps
    print "Starting iteration with #{result.size} periods..\n"
    overlap_map = Hash.new
    no_overlaps = true
    (0..result.size-1).each  do |i|
      wp1 = result[i]
      overlap_map[wp1] = []
      next if i == result.size - 1
      (i+1..result.size-1).each  do |j|
        wp2 = result[j]
        next if wp1 == wp2
        
        if wp2.nil?
          p i
          p j
          p result.size
        end

        if overlaps?(wp1,wp2)
          no_overlaps = false
          overlap_map[wp1] << wp2 
        end
      end
    end

    if no_overlaps
      print "Ending iteration with #{result.size} periods.\n"
      next
    end

    result = []
    res = process_map(overlap_map)
    res.each do |x|
      if x[1].size > 1
        print "Replacing these objects:\n"
        x[1].each do |y|
          print "(#{y["start"]}-#{y["end"]}) (#{y["user_id"]}, #{y["worklog_task_id"]}, #{y["id"]})\n"
        end
        print "..with this object:\n"
        y = merge_periods(x[1])
        print "(#{y["start"]}-#{y["end"]}) (#{y["user_id"]}, #{y["worklog_task_id"]})\n"
        result << y
        wp = WorkPeriod.new(y)
        do_save = true
        x[1].each do |x|
          if x.has_key? "id"
            if WorkPeriod.find(:first, :conditions => ["id = ?", x["id"].to_i])
              WorkPeriod.destroy(x["id"].to_i) if COMMIT
            end
          else
            print "want to delete period without id..\n"
            do_save = false
          end
        end
        if do_save
          wp.save if COMMIT
        end
      else
        result << x[1][0]
      end
    end  

    print "Ending iteration with #{result.size} periods.\n"
  end

  print "Condensed overlaps into the following result:\n"
  result.each do |x|
    print "(#{x["start"]}-#{x["end"]}, #{x["worklog_task_id"]}, #{x["user_id"]}) Comment: #{x["comment"]}\n"
  end

  if u.alias == USER 
    break
  end

  #to_add.each  do |x|
  #  wp = WorkPeriod.new(x)
  #  wp.save
  #  print "Create new period for user #{wp.user.alias}: (#{wp.start}-#{wp.end}), #{wp.worklog_task.name}\n"
  #end
  #to_delete.each do |x|
  #  print "Deleting period with id #{x.id}\n"
  #  WorkPeriod.destroy(x.id)
  #end
end
