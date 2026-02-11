# frozen_string_literal: true

require 'vcr'
require_relative 'workato_test_harness'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end

RSpec.describe 'Generated Connector' do
  include WorkatoTestHarness

  let(:connector) { WorkatoTestHarness.load_connector('connector.rb') }
  let(:connection) do
    { 'domain' => 'beta-loanpro',
      'api_key' => 'kv2_hk5dRlWCbodsEoOZbYx6o9Oitw64qzpq8LpvBBneEW4ne0JQPYAY4435aJxJKIa8YPG1bNc2GT3Ln/hMRDM3Pg==', 'tenant_id' => '518206' }
  end

  it "tests the 'rdn' action execution" do
    VCR.use_cassette('rdn_action') do
      action = connector[:actions][:event_types]
      input = { 'loan_id' => 2, 'note_section' => { 'subject' => 'Test' } }

      @connection = connection

      result = instance_exec(connection, input, &action[:execute])

      expect(result.code).to eq(200)
    end
  end
end
