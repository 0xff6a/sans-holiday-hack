#! /usr/bin/env ruby
#
# Parse the data from SANS Hack the Holidays
#
require 'base64'

infile = 'b64.out'
output = ''

File.open(infile).each do |line|
  decoded = Base64.decode64(line)
  output += decoded.gsub('FILE:', '')
end

File.open('parsed', 'w') do |file|
  file.write(output)
end
