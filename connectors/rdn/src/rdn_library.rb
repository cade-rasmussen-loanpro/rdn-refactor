# frozen_string_literal: true

module RdnFields
  def self.common_fields
    [
      SimpleFields.integer(name: 'loan_id', label: 'Loan ID'),
      SimpleFields.string(name: 'rdn_case_number', label: 'RDN Case Number'),
      SimpleFields.integer(name: 'rdn_case_number_custom_field_id', label: 'RDN Case Number Custom Field ID'),
      SimpleFields.integer(name: 'previous_rdn_case_number_custom_field_id',
                           label: 'Previous RDN Case Number Custom Field ID'),
      SimpleFields.integer(name: 'rdn_last_updated_custom_field_id', label: 'RDN Last Updated Custom Field ID'),
      SimpleFields.string(name: 'rdn_last_updated_value', label: 'RDN Last Updated Value'),
      SimpleFields.object(
        name: 'note_section',
        label: 'Note Parameters',
        properties: [
          SimpleFields.integer(name: 'category_id', label: 'Category Id'),
          SimpleFields.string(name: 'subject', label: 'Subject'),
          SimpleFields.text_area(name: 'body', label: 'Body'),
          SimpleFields.string(name: 'failure_subject', label: 'Failure Subject')
        ]
      )
    ]
  end
  # In RdnFields (e.g. near the top of the module, after common_fields or event_type_fields)

  def self.event_type_fields(event_type)
    fields = case event_type
             when '101'
               [
                 SimpleFields.integer(
                   name: 'custom_field_id_repossesion_type',
                   label: 'Custom Field Id Repossesion Type'
                 )
               ]
             when '300'
               [
                 SimpleFields.integer(
                   name: 'custom_field_id_repossesion_address',
                   label: 'Custom Field Id Repossesion Address'
                 ),
                 SimpleFields.integer(
                   name: 'custom_field_id_repossesion_company',
                   label: 'Custom Field Id Repossesion Company'
                 )
               ]
             when '301'
               [
                 SimpleFields.integer(
                   name: 'loan_status_id',
                   label: 'Loan Status Id'
                 ),
                 SimpleFields.integer(
                   name: 'loan_sub_status_id',
                   label: 'Loan Sub Status Id'
                 ),
                 SimpleFields.integer(
                   name: 'portfolio_ids',
                   label: 'Portfolio IDs'
                 )
               ]
             when '600'
               [
                 SimpleFields.integer(
                   name: 'custom_field_id_rdn_case_vendor_assigned_name',
                   label: 'Custom Field Id RDN Case Vendor Assigned Name'
                 ),
                 SimpleFields.integer(
                   name: 'custom_field_id_rdn_case_vendor_assigned_phone',
                   label: 'Custom Field Id RDN Case Vendor Assigned Phone'
                 ),
                 SimpleFields.integer(
                   name: 'custom_field_id_rdn_case_order_date',
                   label: 'Custom Field Id RDN Case Order Date'
                 )
               ]
             when '602'
               [
                 SimpleFields.integer(
                   name: 'custom_field_id_rdn_case_closed_reason',
                   label: 'Custom Field Id RDN Case Closed Reason'
                 ),
                 SimpleFields.integer(
                   name: 'custom_field_id_rdn_case_closed_date',
                   label: 'Custom Field Id RDN Case Closed Date'
                 )
               ]
             when '603'
               [
                 SimpleFields.integer(
                   name: 'custom_field_id_rdn_case_hold_date',
                   label: 'Custom Field Id RDN Case Hold Date'
                 )
               ]
             when '604'
               [
                 SimpleFields.integer(
                   name: 'custom_field_id_rdn_case_closed_reason',
                   label: 'Custom Field Id RDN Case Closed Reason'
                 ),
                 SimpleFields.string(
                   name: 'close_reason',
                   label: 'Close Reason'
                 )
               ]
             end

    fields || []
  end
end

module RdnActions
  def self.event_types
    {
      title: 'RDN Event Type',
      subtitle: 'RDN implementation',

      config_fields: [
        {
          name: 'event_type',
          label: 'Event Type',
          control_type: 'select',
          pick_list: 'rdn_event_types',
          optional: false
        }
      ],

      input_fields: lambda do |_object_definitions, _connection, config_fields|
        note_fields = RdnFields.common_fields
        event_type_fields = RdnFields.event_type_fields(config_fields['event_type'])

        event_type_fields + note_fields
      end,

      execute: lambda do |_connection, input|
        # LoanProApiClient.request(
        #  self,
        #  method: :put,
        #  endpoint: "odata.svc/Loans(#{input['loan_id']})",
        #  payload: payload
        # )

        params = { "$select": 'id,settingsId' }

        LoanProApiClient.request(
          self,
          method: :get,
          endpoint: "odata.svc/Loans(#{input['loan_id']})?$select=id,settingsId",
          payload: params
        )

        # settings_id = lp_client.fetch_loan(
        #    loan_id,
        #    params={"$select": "id,settingsId"},
        # )["settingsId"]
      end,

      output_fields: lambda do |_object_definitions, _connection, _config_fields|
        [
          { name: 'categoryId', label: 'Category Id', type: 'integer', optional: false, sticky: true,
            control_type: 'integer' },
          { name: 'subject', label: 'Subject', type: 'string', optional: false, sticky: true },
          { name: 'body', label: 'Body', type: 'string', optional: false, sticky: true, control_type: 'text_area' },
          { name: 'payload', label: 'Payload JSON', type: 'string', optional: true, control_type: 'text_area' }
        ]
      end
    }
  end

  def self.base_action
    {
      title: 'Get Loan Information',
      subtitle: 'Using RDN Case ID Get Loan Information',

      config_fields: [
        {
          name: 'rdn_case_number',
          label: 'RDN Case ID',
          control_type: 'string',
          optional: false,
          details: {
            real_name: 'rdn_case_number'
          }
        },
        {
          name: 'rdn_case_number_custom_field_id',
          label: 'Case ID - Custom Field ID',
          control_type: 'integer',
          optional: false,
          details: {
            real_name: 'rdn_case_number_cf_id'
          }
        },
        {
          name: 'previous_rdn_case_number_custom_field_id',
          label: 'Previous Case ID - Custom Field ID',
          control_type: 'integer',
          optional: false,
          details: {
            real_name: 'rdn_previous_case_number_cf_id'
          }
        },
        {
          name: 'rdn_last_updated_custom_field_id',
          label: 'Last Updated - Custom Field ID',
          control_type: 'integer',
          optional: false,
          details: {
            real_name: 'rdn_last_updated_cf_id'
          }
        },
        {
          name: 'rdn_last_updated_value',
          label: 'Last Updated Value',
          control_type: 'string',
          optional: false,
          details: {
            real_name: 'rdn_last_updated_cf_id'
          }
        }
      ],


      execute: lambda do |_connection, input|

        filter_stmt = f"customFieldId eq {input['rdn_case_number_custom_field_id']} and customFieldValue eq '{input['rdn_case_number']}' and entityType eq 'Entity.LoanSettings'"
        params = { "$filter": filter_stmt }
        LoanProApiClient.request(
          self,
          method: :get,
          endpoint: "odata.svc/Loans(#{input['loan_id']})?$select=id,settingsId",
        )
      end,

      output_fields: lambda do |_object_definitions, _connection, _input_fields|
        [
          { name: 'loan_id', label: 'Loan Id', type: 'integer', optional: false, sticky: true,
            control_type: 'integer' },
          { name: 'loan_settings_id', label: 'Loan Settings Id', type: 'string', optional: false, sticky: true,
            control_type: 'integer' },
          { name: 'previous_rdn_case_number', label: 'Previous RDN Case Number', type: 'string', optional: false,
            sticky: true, control_type: 'string' },
          { name: 'rdn_last_updated', label: 'Last Updated', type: 'string', optional: false, sticky: true,
            control_type: 'string' }
        ]
      end

    }
  end
end

module RdnTriggers
  def self.updated_case
    {
      title: "New Event / Update",

      subtitle: "Triggers when a new event is found in RDN.",

      description: lambda do |input, picklist_label|
        "New update or event on a <span class='provider'>case</span> " \
        "in <span class='provider'>RDN</span>"
      end,

      help: "Creates a job when a new event or update is made on a case in " \
      "RDN. Each new event creates a separate job.",

      input_fields: lambda do |_object_definitions|
        [
          {
            name: 'Monitored Event Types',
            label: 'Monitored Event Types',
            control_type: 'multiselect',
            pick_list: 'rdn_event_types',
            optional: false
          }
        ]
      end,
    }
  end
end
