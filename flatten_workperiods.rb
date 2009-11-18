#!/usr/bin/env /Users/patrik/RubymineProjects/jrbh-worklog/script/runner -e production

USER = "JH"
COMMIT = false 
D_START = Date.new(2009,2,28)
D_END = Date.new(2009,3,14)

user = User.find_by_alias(USER)
users = [user]

users.each do |u|
  print "Attempting to flatten periods for user #{u.alias}\n"
  wps = WorkPeriod.find(:all,
                        :conditions => ["user_id = ? and start >= ? and work_periods.end <= ?",
                                        u.id, D_START, D_END])

  periods = wps.sort {|a,b| a.start <=> b.start}
  prev = nil
  cumm = []
  active_chain = false
  periods.each do |p|
    unless prev
      prev = p
      next
    end
    if (prev.worklog_task_id == p.worklog_task_id) and (prev.end == p.start)
      # add period ot the chain
      cumm << prev if cumm == []
      cumm << p
      active_chain = true
    elsif active_chain
      # chain is over, flatten the cumm entries with one entry
      start_t = cumm.first.start
      end_t = cumm.last.end
      comment = ((cumm.select {|x| x.comment != nil and x.comment != ""}).map {|x| x.comment }).join(", ")
      if comment.size > 255
        comment = comment[0..254]
      end
      wltid = cumm.first.worklog_task_id
      print "Flattened #{cumm.size} entries into one entry. These parts:\n"
      # remove old entries
      cumm.each do |x|
        print "(#{x.start}-#{x.end}) #{x.worklog_task.name} - #{x.user.alias}\n"
        x.destroy if COMMIT
      end
      print "..became this:\n"
      # create new entry
      wp = WorkPeriod.create(:user_id => u.id,
                             :worklog_task_id => wltid,
                             :start => start_t,
                             :end => end_t,
                             :comment => comment) if COMMIT
      print "(#{wp.start}-#{wp.end}) #{wp.worklog_task.name} - #{wp.user.alias}\n"

      # reset chain info
      active_chain = false
      cumm = []
    end

    prev = p
  end

  if cumm != []
    # chain is over, flatten the cumm entries with one entry
    start_t = cumm.first.start
    end_t = cumm.last.end
    comment = ((cumm.select {|x| x.comment != nil and x.comment != ""}).map {|x| x.comment }).join(", ")
    if comment.size > 255
      comment = comment[0..254]
    end
    wltid = cumm.first.worklog_task_id
    print "Flattened #{cumm.size} entries into one entry. These parts:\n"
    # remove old entries
    cumm.each do |x|
      print "(#{x.start}-#{x.end}) #{x.worklog_task.name} - #{x.user.alias}\n"
      x.destroy if COMMIT
    end
    print "..became this:\n"
    # create new entry
    wp = WorkPeriod.create(:user_id => u.id,
                           :worklog_task_id => wltid,
                           :start => start_t,
                           :end => end_t,
                           :comment => comment) if COMMIT
    # create new entry
    WorkPeriod.create(:user_id => u.id,
                      :worklog_task_id => cumm.first.worklog_task_id,
                      :start => start_t,
                      :end => end_t,
                      :comment => comment) if COMMIT
    print "(#{wp.start}-#{wp.end}) #{wp.worklog_task.name} - #{wp.user.alias}\n"
  end
end
