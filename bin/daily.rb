# List daily contaminations

$:.unshift(
    File.join(File.dirname(__FILE__), '..'),
    File.dirname(__FILE__)
)
require 'rubygems'
require 'model'

now = Time.now
date = Date.new now.year, now.month
start = Date.new now.year, now.month, 1
stop = Date.new now.year, now.month, 31

Update.filter('created<=?',stop).filter('created>=?',start).order(:created.asc).each do |c|
    puts "#{c.created}: #{c.count}"
end
