require 'rubygems'
require 'roo'

files = [
  'Work Log 2.0_V01_20.07.2009_JUL 09_HL.xls',
  'Work Log 2.0_V02_03.08.2009_AUG 09_HL.xls',
  'Work Log 2.0_V03_07.10.2009_SEP 09_HL.xls',
  'Work Log 2.0_V04_07.10.2009_OCT 09_HL.xls'
];

tabs_to_convert = [
  "JH",
  "JO",
  "HL",
  "MS",
  "PC",
  "RH",
  "AC",
  "DY",
  "PA",
  "BH",
  "PK",
  "ES",
  "GB",
  "1",
  "2",
  "INT"
];

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

