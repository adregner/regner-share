#!/usr/bin/env ruby
require 'mongo'
require 'mongoid'

puts "Loading models..."

Mongoid.load! "config/mongo.yml", :development
Dir["./models/*.rb"].each{ |f| require f }

# cache some things
all_paths = Item.all.map{ |item| item.path }
root = ARGV[0] or throw "Must give a root directory to scan"

# absolutize what we are adding
unless root[0] == "/"
  root = root[2..-1] if root[0..1] == "./"
  root = "#{Dir::pwd}/#{root}"
end
root = root[0..-2] if root[-1] == "/"

puts "Adding all files under #{root}..."

# add all the new things
Dir["#{root}/**/**"].each do |new_path|
  unless all_paths.include?(new_path) or not File::file?(new_path)
    puts "--> #{new_path}"
    item = Item.create!(path: new_path) or throw "Error creating item"
    item.save or throw "Erorr saving item"
  end
end

puts "Looking for things to delete..."

# clean up the things that don't exist anymore
all_paths.each do |old_path|
  unless File::exists? old_path
    puts "--> #{old_path}"
    Item.find_by(path: old_path).delete
  end
end

puts "Done."
