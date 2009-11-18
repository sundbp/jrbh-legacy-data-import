#!/usr/bin/env /Users/patrik/RubymineProjects/jrbh-worklog/script/runner -e production

COMMIT = false 
USER = "JH"
D_START = Date.new(2009,1,17)
D_END = Date.new(2009,1,31)

print "Going to Delete periods between #{D_START} and #{D_END} for user #{USER}.\n"

u = User.find_by_alias(USER)
raise "no user" unless u

wps = WorkPeriod.find(:all,
                      :conditions => ['user_id = ? and start >= ? and work_periods.end <= ?',
                                      u.id, D_START, D_END])

print "Found #{wps.size} matching periods to delete:\n"

wps.each do |x|
  print "(#{x.start}-#{x.end}) #{x.worklog_task.name} - #{x.user.alias}\n"
end

i = 0
wps.each do |x|
  if COMMIT
    WorkPeriod.destroy(x.id)
    i += 1
  end
end
print "Deleted #{i} work periods.\n"
