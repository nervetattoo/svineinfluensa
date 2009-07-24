# Update contaminations from MSIS
# http://www.msis.no/emsisexternalweb/DynamiskRapport.aspx

$:.unshift(
    File.join(File.dirname(__FILE__), '..'),
    File.dirname(__FILE__)
)
require 'rubygems'
require 'nokogiri'
require 'restclient'
require 'model/init'


# What month to update?
if ARGV[0] != nil and ARGV[0].to_i >= 1 and ARGV[0].to_i <= 12
    month = ARGV[0]
else
    month = Date.today.mon()
end

# List of POST params to send

url = "http://www.msis.no/emsisexternalweb/DynamiskRapport.aspx"
# First we need to make sure we get some cookies, bastards
headers = {
    :user_agent => "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.11) Gecko/2009060308 Ubuntu/9.04 (jaunty) Firefox/3.0.11",
    :referer => "http://www.msis.no/emsisexternalweb/DynamiskRapport.aspx",
    :connection => 'keep-alive',
    :keep_alive => '300',
    :accept_charset => 'ISO-8859-1,utf-8;q=0.7,*;q=0.7',
    :accept => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
}

resource = RestClient::Resource.new(url, :headers => headers);
resp = resource.get
# Use Nokogiri to parse the get response
# to find the viewstate to send
noko = Nokogiri::HTML.parse(resp.to_s)
viewstate = noko.css('input[name="__VIEWSTATE"]').first.get_attribute('value')
# Make the real request
cookie = 'ASP.NET_SessionId'
#response = RestClient.post url, {
response = resource.post({:'__EVENTARGUMENT' => '',
    :'__EVENTTARGET' => '',
    :'__VIEWSTATE' => viewstate,
    :m_ctrlAldersgruppe => 'Alle',
    :m_ctrlDiagnose => 49437,
    :m_ctrlFylke => 'Alle',
    :m_ctrlKjonn => 'Alle',
    :m_ctrlKolonner => 0,
    :m_ctrlLagRapport => "Lag+tabell",
    :m_ctrlMonths => month,
    :m_ctrlRader => 1,
    :m_ctrlSmitteverdensdel => 'Alle',
    :m_ctrlYears => 2009},
    {:cookies => {:'ASP.NET_SessionId' => resp.cookies[cookie]}})

# Houston, we have lift off
# Now parse that motherfucker with nokogiri
document = Nokogiri::HTML.parse(response.to_s)
# Find counties
i = 1
total = 0
document.css('table tr td font div').each do |node|
    i = i + 1
    # Find women value
    women = document.css("table#m_ucReportGrid_m_ctrlRapportGrid tr:nth-of-type(2) td:nth-of-type(#{i}) font").first.content
    men = document.css("table#m_ucReportGrid_m_ctrlRapportGrid tr:nth-of-type(2) td:nth-of-type(#{i}) font").first.content
    if women == '-'
        women = 0
    end
    if men == '-'
        men = 0
    end
    cnt = node.content.to_s
    county = County[:name=>cnt]
    contamination = Contamination.create :count_male => men,
        :count_female => women, :year => 2009,
        :month => month
    contamination.county = county
    puts "Added [#{cnt}] Men:#{men} Women:#{women}"
    total = total.to_i + men.to_i + women.to_i
end
# Finalize
Update.create :time => Time.now.to_i,
    :count => total
puts "Finalized update. Total for this update was: #{total}"
