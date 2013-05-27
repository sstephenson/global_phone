$:.unshift File.expand_path("../lib", __FILE__)
require "global_phone"

Gem::Specification.new do |s|
  s.name = "global_phone"
  s.version = GlobalPhone::VERSION
  s.summary = "Parse, validate, and format phone numbers using Google's libphonenumber database"
  s.description = "GlobalPhone parses, validates, and formats local and international phone numbers according to the E.164 standard using the rules specified in Google's libphonenumber database."
  s.license = "MIT"

  s.files = Dir["README.md", "LICENSE", "lib/**/*.rb"]
  s.files.delete_if { |filename| filename =~ /database_generator/ }

  s.authors = ["Sam Stephenson"]
  s.email = ["sstephenson@gmail.com"]
  s.homepage = "https://github.com/sstephenson/global_phone"
end
