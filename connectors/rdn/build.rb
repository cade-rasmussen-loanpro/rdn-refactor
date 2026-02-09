require 'erb'
require 'ostruct'

config = {
  title: "RDN Connector SDK",
  connection: File.read('../../lib/lms/api_connection.rb'),
  actions: File.read('./src/actions.rb'),
  pick_lists: File.read('./src/pick_lists.rb'),
  libraries: [ 
    File.read('../../lib/loanpro/loanpro_apli_client.rb'),
    File.read('./src/rdn_library.rb')
  ],
  methods: {},
  test: "lambda { |connection| post('Loans/Autopal.Search()?$top=1') }"
}

template = File.read('../template_connector.rb.erb')

vars = OpenStruct.new(config)


renderer = ERB.new(template)
result = renderer.result(vars.instance_eval { binding })

File.write('connector.rb', result)
#system("bundle exec rubocop -a --only Layout connector.rb")

#system("bundle exec rubocop -A --only Layout/IndentationWidth,Layout/IndentationConsistency,Layout/HashAlignment connector.rb > /dev/null 2>&1")
system("bundle exec standardrb --fix connector.rb")

result = File.read('./connector.rb')
puts result
puts "connector.rb generated successfully"