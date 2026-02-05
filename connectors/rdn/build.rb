require 'erb'
require 'ostruct'

config = {
  title: "RDN Connector SDK",
  connection: File.read('../../lib/lms/api_connection.rb'),
  actions: File.read('./src/actions.rb'),
  pick_lists: File.read('./src/pick_lists.rb'),
  libraries: File.read('./src/rdn_library.rb'),
  methods: {},
  test: "lambda { |connection| post('Loans/Autopal.Search()?$top=1') }"
}

template = File.read('../template_connector.rb.erb')

vars = OpenStruct.new(config)


renderer = ERB.new(template)
result = renderer.result(vars.instance_eval { binding })
File.write('connector.rb', result)
puts result
puts "connector.rb generated successfully"