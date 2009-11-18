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

