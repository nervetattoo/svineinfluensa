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
            'Nord-Trøndelag','Nordland','Troms','Finnmark',
            'Utenfor Fastlands-Norge', 'Ukjent fylke']
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
        integer :count_unknown
        integer :year, :empty=>false
        integer :month, :empty=>false
        foreign_key :county_id
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
        integer :count, :empty=>false
        date :created
    end
    create_table unless table_exists?
end

'''
# Better contamination model
class Incident < Sequel::model
    set_schema do
        primary_key :id
        integer :count, :empty=>false
        time :created
        varchar :sex, :empty=>false
        foreign_key :age_group_id
        foreign_key :county_id
    end
    create_table unless table_exists?
end

class AgeGroup < Sequel::Model
    set_schema do
        primary_key :id
        varchar :title, :unique=>true
        integer :start
        integer :end
    end
    create_table unless table_exists?
    if empty?
        # Create all agegroups
        create :title => "0-9", :start => 0, :end => 9
        create :title => "10-19", :start => 10, :end => 19
        create :title => "20-29", :start => 20, :end => 29
        create :title => "30-39", :start => 30, :end => 39
        create :title => "40-49", :start => 40, :end => 49
        create :title => "50-59", :start => 50, :end => 59
        create :title => "60-69", :start => 60, :end => 69
        create :title => "70-79", :start => 70, :end => 79
        create :title => "80-89", :start => 80, :end => 89
        create :title => "90+", :start => 90, :end => 120
    end
end
'''
