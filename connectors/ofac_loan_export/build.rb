require 'erb'
require 'ostruct'

config = {
  title: "OFAC Loan Export - SDK",
  connection: File.read('../../lib/aws/client_connection.rb'),
  triggers: File.read('./src/triggers.rb'),
  actions: File.read('./src/actions.rb'),
  methods: File.read('./src/methods.rb'),
  test: "lambda { |connection| call(:list_buckets, connection) }"
}

template = File.read('../template_connector.rb.erb')

vars = OpenStruct.new(config)

renderer = ERB.new(template)
result = renderer.result(vars.instance_eval { binding })
File.write('connector.rb', result)
puts result
puts "connector.rb generated successfully"