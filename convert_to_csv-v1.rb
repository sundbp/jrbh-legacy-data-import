require 'rubygems'
require 'roo'

files = [
  '01 Worklog RAW DATA - 28.07.09 to 03.01.09_HL.xls',
  '02 Worklog RAW DATA - 03.01.09 to 04.04.09_HL.xls',
  '03 Worklog RAW DATA - 04.04.09 to 27.06.09_HL.xls'
];

tabs_to_convert = ["JH", "AB", "JO", "RH", "ES", "HL", "NK", "MS", "GB", "AC"];

files.each do |fname|
  doc = Excel.new(fname)
  tabs_to_convert.each do |tab|
    begin
      doc.default_sheet = tab
      doc.to_csv("output/" + tab + " - " + fname[0..-4]+"csv")
    rescue Exception => e
      print e.to_s + "\n"
      next
    end
  end
  print "Converted file: " + fname + "\n"
end

