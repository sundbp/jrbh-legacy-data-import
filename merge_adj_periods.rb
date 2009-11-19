#!/usr/bin/env /Users/patrik/RubymineProjects/jrbh-worklog/script/runner -e production

COMMIT = false 
USER = "JH"

print "Going to merge adjescent eriods for user #{USER}.\n"

u = User.find_by_alias(USER)
raise "no user" unless u

wps = WorkPeriod.find(

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
