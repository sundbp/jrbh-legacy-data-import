#!/usr/bin/env /Users/patrik/RubymineProjects/jrbh-worklog/script/runner -e production

def overlaps?(wp1, wp2)
  if wp1.nil? or wp2.nil?
    print "found a nil:\n"
    p wp1
    p wp2
  end

  if wp1["start"] > (wp2["end"]-1.minute) or wp1["end"] < (wp2["start"]+1.minute)
    false
  else
    true
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

User.find(:all).each do |u|
  print "\nSearching for matches for user #{u.alias}\n"
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
        print "(#{wp1.start}-#{wp1.end}, #{wp1.worklog_task.name}) and (#{wp2.start}-#{wp2.end}, #{wp2.worklog_task.name}) (#{wp1.id}, #{wp2.id})\n"
      end
    end
  end
end

