
WorkPeriodStruct = Struct.new(:start,:end,:user,:task,:comment)

dumps = []
Dir['*/*.dump'].each do |fname|
  print "adding #{fname}:\n"
  File.open(fname) do |f|
    dumps << Marshal.load(f)
  end
end

dumps.each do |o|
  o.sort! do |a,b| a.start <=> b.start end
  print "Range of data is: " + o[0].start.to_s + " - " + o[-1].end.to_s + "\n"
end

data = dumps.first
dumps.each do |o|
  next if data == o 
  data = data.concat(o)
end
data.sort! do |a,b| a.start <=> b.start end

print "We have " + data.size.to_s + " records of data\n"
print "Range of data is: " + data[0].start.to_s + " - " + data[-1].end.to_s + "\n"

data.each do |x|
  if x.start > Time.now
    p x
  end
  # remap C- and P- task names
  if x.task =~ /([PC])-(.*)/
    if $1 == "P"
      x.task = $2 + " - Pitching"
    else
      x.task = $2
    end
  end

end

File.open(ARGV[0], "w+" ) do |f|
  Marshal.dump(data, f)
end

users = data.map {|x| x.user }
print "List of users occuring in the data:\n"
users.uniq.sort.each {|x| print x + "\n"}
tasks = data.map {|x| x.task }
print "List of tasks occuring in the data:\n"
tasks.uniq.sort.each {|x| print x + "\n"}
#tasks.uniq.sort.each {|x| p x}

task_to_company = {
  "Admin" => "JRBH",
  "B.Com - Pitching" => "JRBH",
  "Board Consulting - Pitching" => "JRBH",
  "Break" => "JRBH",
  "Compass" => "Compass",
  "Educor 2" => "Educor",
  "Educor 3" => "Educor",
  "Energy Foresight" => "Energy Foresight",
  "HR" => "JRBH",
  "Holiday" => "JRBH",
  "Idis" => "Idis",
  "Idis - Pitching" => "Idis",
  "Internal" => "JRBH",
  "JRBH Review" => "JRBH",
  "Laird" => "Laird",
  "Lunch" => "JRBH",
  "Marketing" => "JRBH",
  "Mini MBA - Pitching" => "JRBH",
  "NBD" => "JRBH",
  "Oxford Economics" => "Oxford Economics",
  "P3 Universal" => "Universal",
  "RBS" => "RBS",
  "Sibeth" => "Sibeth",
  "Sickness" => "JRBH",
  "Spring Break" => "JRBH",
  "Standard Life" => "Patrick Snowball",
  "Stanton Chase" => "Stanton Chase",
  "T&D" => "JRBH",
  "Unibalm" => "Unibalm",
  "Universal" => "Universal",
  "Verisae" => "Verisae",
  "Verisae - Pitching" => "Verisae",
  "Verisae2 - Pitching" => "Verisae",
  "Verisae3 - Pitching" => "Verisae",
  "Wiley" => "Wiley",
  "Worklog" => "JRBH"
}

File.open('worklog_task_company.dump', "w+" ) do |f|
  Marshal.dump(task_to_company, f)
end
