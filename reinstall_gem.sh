gem uninstall global_phone
gem uninstall global_phone_dbgen
gem build global_phone.gemspec 
gem build global_phone_dbgen.gemspec 
gem install global_phone-1.0.1.gem
gem install global_phone_dbgen-1.0.1.gem
global_phone_dbgen > global_phone.json