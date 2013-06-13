require 'rubygems'
require 'global_phone'
require 'benchmark'

GlobalPhone.db_path = './global_phone.json'

array = Array.new(7)
execution_time = Benchmark.measure do 
  array[0] = GlobalPhone.parse "+14153708689"
  array[1] = GlobalPhone.parse "+19058473689"
  array[2] = GlobalPhone.parse "+912027471234"
  array[3] = GlobalPhone.parse "+34628437654"
  array[4] = GlobalPhone.parse "+17873462345"
  array[5] = GlobalPhone.parse "+919422516234"
  array[6] = GlobalPhone.parse "+9194225162345"
end
puts execution_time
array.each do |x|  
  puts "#{x.territory.name}, #{x.country_code} + #{x.national_string}, Type - #{x.type}, Fixed - #{x.fixed_line?}, Mobile - #{x.mobile?}"  if x
end
