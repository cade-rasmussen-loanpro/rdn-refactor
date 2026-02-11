# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'RDN Connector Logic' do
  describe RdnFields do
    describe '.common_fields' do
      let(:fields) { RdnFields.common_fields }

      it 'includes the loan_id as the first field' do
        expect(fields.first[:name]).to eq('loan_id')
      end

      it 'includes the note_section object with correct properties' do
        note_section = fields.find { |f| f[:name] == 'note_section' }
        expect(note_section[:type]).to eq('object')

        props = note_section[:properties]
        expect(props.any? { |p| p[:name] == 'category_id' }).to be true
        expect(props.any? { |p| p[:name] == 'subject' }).to be true
        expect(props.any? { |p| p[:name] == 'body' }).to be true
      end
    end

    describe '.event_type_fields' do
      it 'returns specific fields for event_type 101' do
        fields = RdnFields.event_type_fields('101')

        expect(fields.first[:name]).to eq('custom_field_id_repossesion_type')
      end

      it 'returns specific fields for event_type 300' do
        fields = RdnFields.event_type_fields('300')

        expect(fields[0][:name]).to eq('custom_field_id_repossesion_address')
        expect(fields[1][:name]).to eq('custom_field_id_repossesion_company')
      end

      it 'returns specific fields for event_type 301' do
        fields = RdnFields.event_type_fields('301')

        expect(fields[0][:name]).to eq('loan_status_id')
        expect(fields[1][:name]).to eq('loan_sub_status_id')
        expect(fields[2][:name]).to eq('portfolio_ids')
      end

      it 'returns specific fields for event_type 600' do
        fields = RdnFields.event_type_fields('600')

        expect(fields[0][:name]).to eq('custom_field_id_rdn_case_vendor_assigned_name')
        expect(fields[1][:name]).to eq('custom_field_id_rdn_case_vendor_assigned_phone')
        expect(fields[2][:name]).to eq('custom_field_id_rdn_case_order_date')
      end

      it 'returns specific fields for event_type 602' do
        fields = RdnFields.event_type_fields('602')

        expect(fields[0][:name]).to eq('custom_field_id_rdn_case_closed_reason')
        expect(fields[1][:name]).to eq('custom_field_id_rdn_case_closed_date')
      end

      it 'returns specific fields for event_type 603' do
        fields = RdnFields.event_type_fields('603')

        expect(fields[0][:name]).to eq('custom_field_id_rdn_case_hold_date')
      end

      it 'returns specific fields for event_type 604' do
        fields = RdnFields.event_type_fields('604')

        expect(fields[0][:name]).to eq('custom_field_id_rdn_case_closed_reason')
        expect(fields[1][:name]).to eq('close_reason')
      end

      it 'returns empty array for an unknown event_type' do
        expect(RdnFields.event_type_fields('unknown')).to eq([])
      end
    end
  end

  describe RdnActions do
    describe 'event_types definition' do
      let(:action) { RdnActions.event_types }

      it 'has the correct title' do
        expect(action[:title]).to eq('RDN Event Type')
      end

      it 'has the correct config fields' do
        config_fields = action[:config_fields].first

        expect(config_fields[:name]).to eq('event_type')
        expect(config_fields[:label]).to eq('Event Type')
        expect(config_fields[:control_type]).to eq('select')
        expect(config_fields[:pick_list]).to eq('rdn_event_types')
        expect(config_fields[:optional]).to eq false
      end

      describe 'input_fields lambda' do
        it 'combines event fields and common fields correctly' do
          config_fields = { 'event_type' => '101' }

          fields = action[:input_fields].call(nil, nil, config_fields)

          field_names = fields.map { |f| f[:name] }
          expect(field_names).to include('custom_field_id_repossesion_type')
          expect(field_names).to include('loan_id')
          expect(field_names).to include('note_section')
        end
      end

      describe 'output_fields lambda' do
        it 'send correct output fields' do
          fields = action[:output_fields].call(nil, nil, nil)

          field_names = fields.map { |f| f[:name] }
          expect(field_names).to include('categoryId')
          expect(field_names).to include('subject')
          expect(field_names).to include('body')
          expect(field_names).to include('payload')
        end
      end
    end
  end
end
