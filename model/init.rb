# Here goes your database connection and options:
require 'sequel'

Sequel::Model.plugin(:schema)
DB = Sequel.sqlite('h1n1.db')

# Define all norwegian counties
class County < Sequel::Model
    set_schema do
        primary_key :id

        varchar :name, :unique => true, :empty => false
    end
    one_to_many :contaminations
    create_table unless table_exists?
    if empty?
        # Create all norwegian counties
        counties = ['Østfold','Akershus','Oslo','Hedmark','Oppland','Buskerud',
            'Vestfold','Telemark','Aust-Agder','Vest-Agder','Rogaland',
            'Hordaland','Sogn og Fjordane','Møre og Romsdal','Sør-Trøndelag',
            'Nord-Trøndelag','Nordland','Troms','Finnmark','Utenfor Norge',
            'Ukjent Fylke']
        counties.each do |c|
            create :name => c
        end
    end
end

class Contamination < Sequel::Model
    set_schema do
        primary_key :id

        integer :count_male
        integer :count_female
        integer :year, :empty=>false, :unique=>true
        integer :month, :empty=>false, :unique=>true
    end
    many_to_one :county
    create_table unless table_exists?
end

# Updated each time the script gets runned
# so we can keep track of changes from day to day
# in total contaminations
class Update < Sequel::Model
    set_schema do
        primary_key :id
        integer :time, :empty=>false
        integer :count, :empty=>false
    end
    create_table unless table_exists?
end
