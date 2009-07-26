$:.unshift(
    File.join(File.dirname(__FILE__), '..'),
    File.dirname(__FILE__)
)
require 'rubygems'
require 'sinatra'
require 'haml'
require 'model'

get '/' do
    @contaminations = Contaminations.all
end
