#!/usr/bin/env ruby
require 'erb'

template = File.read('src/template_connector.rb.erb')
result = ERB.new(template).result
File.write('connector.rb', result)

puts "connector.rb generated successfully"
