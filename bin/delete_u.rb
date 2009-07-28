# List daily contaminations

$:.unshift(
    File.join(File.dirname(__FILE__), '..'),
    File.dirname(__FILE__)
)
require 'rubygems'
require 'model'

id = ARGV[0]
u = Update[ARGV[0]]
u.delete
puts "Deleted Update [#{id}]"
