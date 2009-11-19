require 'rubygems'
require 'roo'

tabs_to_convert = ["JH", "AB", "JO", "RH", "ES", "HL", "NK", "MS", "GB", "AC", "DY", "MW"];

counter = 1
Dir[File.join(ARGV[0],'*.xls')].each do |fname|
  doc = Excel.new(fname)
  tabs_to_convert.each do |tab|
    begin
      doc.default_sheet = tab
      doc.to_csv(ARGV[0]+"/output/" + tab + " - " + counter.to_s + ".csv")
    rescue Exception => e
      print e.to_s + "\n"
      next
    end
  end
  print "Converted file: " + fname + "\n"
  counter += 1
end

