$:.unshift(
    File.join(File.dirname(__FILE__), '..'),
    File.dirname(__FILE__)
)
require 'rubygems'
require 'sinatra'
require 'haml'
require 'model'
require 'json'

get '/' do
    month = Time.now.month
    @data =[] 
    County.order(:name.asc).each do |c|
        set = Contamination.filter(:county_id=>c.id,:year=>2009,
            :month=>month).first
        @data << { :county => c.name,
            :male => set.count_male, :female => set.count_female}
    end
    @data.each do |d|
    end
    @total = DB[:contaminations].sum(:count_male) +
        DB[:contaminations].sum(:count_female)
    # Enforce utf-8 so things looks neat
    content_type 'text/html', :charset => 'utf-8'
    haml :index
end

get '/:year' do
    content_type :json
    {:status => true, :message => "#{params[:year]}",
        :data => get_stats(:year=>params[:year])}.to_json
end

get '/:year/:month' do
    content_type :json
    {:status => true, :message => "#{params[:year]}-#{params[:month]}",
        :data => get_stats(:year=>params[:year], :month=>params[:month])}.to_json
end

def get_stats(opts)
    data = []
    County.order(:name.asc).each do |c|
        male = 0
        female = 0
        conts = Contamination.filter(:county_id=>c.id)
        conts = conts.filter(:year=>opts[:year]) if opts[:year] != nil
        conts = conts.filter(:month=>opts[:month]) if opts[:month] != nil
        conts.each do |d|
            male = male + d.count_male
            female = female + d.count_female
        end
        data << { :county => c.name,
            :male => male, :female => female}
    end
    data
end
