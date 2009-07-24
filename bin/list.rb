$:.unshift(
    File.join(File.dirname(__FILE__), '..'),
    File.dirname(__FILE__)
)
require 'rubygems'
require 'model/init'

Contamination.all.each do |c|
    puts "#{c.year}.#{c.month} Men: #{c.count_male} Women: #{c.count_female}"
end
