require_relative '../src/rdn_library'

RSpec.describe RdnLibrary do
  
  describe '.input_fields_for_rdn' do
    let(:config) { { "event_type" => "100" } }
    let(:fields) { RdnLibrary.input_fields_for_rdn(config) }

    it 'returns an Array' do
      expect(fields).to be_an(Array)
    end

    it 'includes the required loan_id field' do
      loan_id_field = fields.find { |f| f[:name] == "loan_id" }
      expect(loan_id_field).not_to be_nil
      expect(loan_id_field[:type]).to eq("integer")
    end

    it 'contains the note_section as an object' do
      note_section = fields.find { |f| f[:name] == "note_section" }
      expect(note_section[:type]).to eq("object")
      expect(note_section[:properties]).to be_an(Array)
    end
  end

  describe '.rdn_action_definition' do
    let(:action) { RdnLibrary.rdn_action_definition }

    it 'has the basic Workato metadata' do
      expect(action[:title]).to eq("RDN Event Type")
      expect(action[:config_fields]).to be_an(Array)
    end

    it 'contains lambdas for the logic blocks' do
      expect(action[:input_fields]).to respond_to(:call)
      expect(action[:execute]).to respond_to(:call)
    end
  end
end