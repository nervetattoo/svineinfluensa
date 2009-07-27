$:.unshift(
    File.join(File.dirname(__FILE__), '..'),
    File.dirname(__FILE__)
)
require 'rubygems'
require 'sinatra'
require 'memcache'
require 'haml'
require 'model'
require 'json'

# Always keep updated date in handy
before do
    @updated = Update.order(:created.desc).last
end

# Just ship all errors to the frontpage
not_found do
    redirect '/'
end

# Frontpage, renders some nice stats
get '/' do
    cache = MemCache.new 'localhost:11211', :namespace=>'h1n1'
    cache.add('/', 'f', 3600) if cache.get '/' == nil
    rendered = cache.get '/'
    if rendered == nil
        month = Time.now.month
        @latest =[] 
        @all =[] 
        @total = {
            :all_m => 0,
            :all_f => 0,
            :all_u => 0,
            :latest_m => 0,
            :latest_f => 0,
            :latest_u => 0,
        }
        counties = County.all
        counties.each do |c|
            set = Contamination.filter(:county_id=>c.id,:year=>2009,
                :month=>month).first
            @latest << { :county => c.name,
                :male => set.count_male, :female => set.count_female,
                :unknown => set.count_unknown }
            count_m = 0
            count_f = 0
            count_u = 0
            Contamination.filter(:county_id=>c.id).each do |cc|
                count_m = count_m + cc.count_male
                count_f = count_f + cc.count_female
                count_u = count_u + cc.count_unknown
            end
            @all << { :county => c.name,
                :male => count_m, :female => count_f, :unknown => count_u}
            # Calculate totals
            @total[:all_m] = @total[:all_m] + count_m
            @total[:all_f] = @total[:all_f] + count_f
            @total[:all_u] = @total[:all_u] + count_u
            @total[:latest_m] = @total[:latest_m] + set.count_male
            @total[:latest_f] = @total[:latest_f] + set.count_female
            @total[:latest_u] = @total[:latest_u] + set.count_unknown
        end
        # Enforce utf-8 so things looks neat
        content_type 'text/html', :charset => 'utf-8'
        puts "Cached"
        rendered = haml :index
        cache.set('/', rendered, 600)
    else
        puts "Read from cache"
    end
    rendered
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
