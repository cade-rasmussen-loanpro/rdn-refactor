require 'vcr'
require_relative 'workato_test_harness'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end

RSpec.describe "Generated Connector" do
  include WorkatoTestHarness

  let(:connector) { WorkatoTestHarness.load_connector('connector.rb') }
  let(:connection) { { 'domain' => 'sandbox', 'api_key' => 'token', 'tenant_id' => '123' } }

  it "tests the 'rdn' action execution" do
    VCR.use_cassette('rdn_action') do
      action = connector[:actions][:event_types]
      input = { 'loan_id' => 456, 'note_section' => { 'subject' => 'Test' } }
      
      @connection = connection
      
      result = instance_exec(connection, input, &action[:execute])
      
      expect(result.code).to eq(200)
    end
  end

end