#!/usr/bin/env /Users/patrik/RubymineProjects/jrbh-worklog/script/runner -e production

USER = "all-users"
PRINT = true 
COMMIT = false 
D_START = Date.new(2008,7,28)
D_END = Date.new(2009,7,4)

# change this path to where your dump is
data_dump_file = "/Users/patrik/Documents/Worklog/worklog_total.dump"
task_company_file = "/Users/patrik/Documents/Worklog/worklog_task_company.dump"

WorkPeriodStruct = Struct.new(:start,:end,:user,:task,:comment)

# various mappings 
alias_to_user = {
        "JH" => "jenharris",
        "JO" => "josbaldaston",
        "MS" => "msim",
        "PC" => "pcroney",
        "HL" => "hleivers"
        }

admins = ["JH", "JO"]

# create users
alias_to_user.each_pair do |key,value|
  next if User.find_by_alias(key)
  admin = admins.include? key
  User.create(:login => value, :alias => key, :admin => admin) if COMMIT
  print "Created user '#{key}'\n"
end

task_to_company = nil
File.open(task_company_file) do |f|
  task_to_company = Marshal.load(f)
end

#create companies
task_to_company.values.uniq.sort.each do |c|
  next if Company.find_by_name(c)
  Company.create(:name => c) if COMMIT
  print "Created company '#{c}'\n"
end

#create worklog tasks
task_to_company.each_pair do |task,company|
  next if WorklogTask.find_by_name(task)
  c = Company.find_by_name(company)
  WorklogTask.create(:name => task, :company_id => c.id) if COMMIT
  print "Created worklog task '#{task}'\n"
end

data = nil
File.open(data_dump_file) do |f|
  data = Marshal.load(f)
end


i = 0
data.each do |x|
  if USER == "all-users"
    next unless x.start >= D_START and x.end <= D_END
  else
    next unless x.user == USER and x.start >= D_START and x.end <= D_END
  end
  t = WorklogTask.find_by_name(x.task) 
  print "(#{x.start}-#{x.end}) #{x.user} - #{x.task}\n" if PRINT

  u = User.find_by_alias(x.user) 
  unless u
    User.create(:login => x.user+"login", :alias => x.user, :admin => false) if COMMIT
    u = User.find_by_alias(x.user)
  end
  
  WorkPeriod.create(:user_id => u.id, :worklog_task_id => t.id, :start => x.start, :end => x.end, :comment => x.comment) if COMMIT
  i = i + 1
end
print "Creataed #{i} work periods.\n"
