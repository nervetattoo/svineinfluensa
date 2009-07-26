$:.unshift(
    File.join(File.dirname(__FILE__), '..'),
    File.dirname(__FILE__)
)
require 'rubygems'
require 'sinatra'
require 'haml'
require 'model'
require 'json'

before do
    @updated = Update.order(:created.desc).last
    puts @updated.created
end

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

#get '/:year' do
get %r{/([0-9]{4}/?$)} do
    year = params[:captures].first
    content_type :json
    {:status => true, :message => "#{year}",
        :data => get_stats(:year=>year)}.to_json
end

#get '/:year/:month' do
get %r{/([0-9]{4})/([0-9]{1,2})} do
    year = params[:captures].first
    month = params[:captures][1]
    content_type :json
    {:status => true, :message => "#{year}-#{month}",
        :data => get_stats(:year=>year, :month=>month)}.to_json
end

# Get county specific stats
get '/:county' do
    # Nasty stuff to try and ensure that capitalization etc is as correct as
    # possible
    county_name = params[:county].split('-').collect{|v| v.capitalize}.
        join('-').split(' ').collect{|v| (v=='og')?v:v.capitalize}.join(' ')
    county = County[:name => county_name]
    content_type :json
    if county != nil
        c = Contamination.filter(:county_id => county.id).order(:month.desc)
        data = []
        c.each do |p|
            data << {:year=>p.year, :month=>p.month,
                :male=>p.count_male,:female=>p.count_female}
        end
        {:status => true, :message => "#{county.name}",
            :data => data}.to_json
    else
        {:status => false, :message => "Fylke eksisterer ikke"}.to_json
    end
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
