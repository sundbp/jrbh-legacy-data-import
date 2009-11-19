WorkPeriodStruct = Struct.new(:start,:end,:user,:task,:comment)

def overlaps?(wp1, wp2)
  if wp1.start > (wp2.end-1) or wp1.end < (wp2.start+1)
    false
  else
    true
  end
end

def print_wp(wp)
  print "(#{wp.start}-#{wp.end}), #{wp.task}, #{wp.user}\n"
end

dump = nil
File.open(ARGV[0]) do |f|
  dump = Marshal.load(f)
end

dump_by_user = Hash.new
dump.each do |x|
  dump_by_user[x.user] = [] unless dump_by_user.has_key? x.user
  dump_by_user[x.user] << x
end

dump_by_user.each do |user, wps|
  wps.sort! {|a,b| a.start <=> b.start}
  (0..wps.size-2).each do |i|
    if wps[i].start >= wps[i].end
      print "found zero(or negative) time period:\t"
      print_wp(wps[i])
    end
    if overlaps?(wps[i], wps[i+1])
      print "Found overlap between following periods:\n"
      print_wp(wps[i])
      print_wp(wps[i+1])
    end
  end
end
