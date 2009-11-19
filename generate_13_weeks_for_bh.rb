#!/usr/bin/env /Users/patrik/RubymineProjects/jrbh-worklog/script/runner -e production

USER = "BH"
COMMIT = false 

u = User.find_by_alias("BH")
t = WorklogTask.find_by_name("Spring Break")
s = Date.new(2009,5,25).to_time
e = Date.new(2009,8,17).to_time

(s..e).step(7.days) do |x|
  start_t = x.to_time + 9.hours
  end_t = start_t + 8.hours 
  print "\n(#{start_t}-#{end_t}) #{u.alias} - #{t.name}\n"
  WorkPeriod.create(:user_id => u.id, :worklog_task_id => t.id, :start => start_t, :end => end_t, :comment => "2days a week import") if COMMIT
  start_t += 1.day
  end_t += 1.day
  print "(#{start_t}-#{end_t}) #{u.alias} - #{t.name}\n"
  WorkPeriod.create(:user_id => u.id, :worklog_task_id => t.id, :start => start_t, :end => end_t, :comment => "2days a week import") if COMMIT
end
