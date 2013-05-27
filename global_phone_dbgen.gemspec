$:.unshift File.expand_path("../lib", __FILE__)
require "global_phone"

Gem::Specification.new do |s|
  s.name = "global_phone_dbgen"
  s.version = GlobalPhone::VERSION
  s.summary = "Generate databases for use with the GlobalPhone library"
  s.description = "Provides a global_phone_dbgen command to generate databases for the GlobalPhone library."
  s.license = "MIT"

  s.files = Dir["README.md", "LICENSE", "lib/global_phone/database_generator.rb"]
  s.executables = ["global_phone_dbgen"]

  s.add_dependency "nokogiri", "~> 1.5"

  s.authors = ["Sam Stephenson"]
  s.email = ["sstephenson@gmail.com"]
  s.homepage = "https://github.com/sstephenson/global_phone"
end
