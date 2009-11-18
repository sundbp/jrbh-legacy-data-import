#!/usr/bin/env /Users/patrik/RubymineProjects/jrbh-worklog/script/runner -e production

USER = nil
MAX_GAP_DAYS = 3

users = if USER
          [User.find_by_alias(USER)]
        else
          User.find(:all)
        end

users.each do |u|
  print "Attempting to find gaps longer than #{MAX_GAP_DAYS} days for user #{u.alias}:\n"
  wps = WorkPeriod.find(:all, :conditions => ["user_id = ?", u.id])
  periods = wps.sort {|a,b| a.start <=> b.start}
  (0..periods.size-2).each do |i|
    wp1 = periods[i]
    wp2 = periods[i+1]
    if wp2.start - wp1.end >= MAX_GAP_DAYS.days
      print "Gap found:\n"
      print "Period1 ends:\t#{wp1.end} (#{wp1.worklog_task.name}, #{wp1.user.alias})\n"
      print "Period2 starts:\t#{wp2.start} (#{wp2.worklog_task.name}, #{wp2.user.alias})\n"
    end
  end
  print "\n\n"
end
