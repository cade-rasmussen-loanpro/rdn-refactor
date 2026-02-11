module RdnFields
  def self.common_fields
    [
      SimpleFields.integer(name: "loan_id", label: "Loan ID"),
      SimpleFields.object(
        name: "note_section",
        label: "Note Parameters",
        properties: [
          SimpleFields.integer(name: "category_id", label: "Category Id"),
          SimpleFields.string(name: "subject", label: "Subject"),
          SimpleFields.text_area(name: "body", label: "Body")
        ]
      )
    ]
  end

  def self.event_type_fields(event_type)
    fields = if event_type == "101"
      [
        SimpleFields.integer(
          name: "custom_field_id_repossesion_type", 
          label: "Custom Field Id Repossesion Type"
        )
      ]      
    elsif event_type == "300"
      [
        SimpleFields.integer(
          name: "custom_field_id_repossesion_address", 
          label: "Custom Field Id Repossesion Address"
        ),
        SimpleFields.integer(
          name: "custom_field_id_repossesion_company", 
          label: "Custom Field Id Repossesion Company"
        ),        
      ]      
    elsif event_type == "301"
      [
        SimpleFields.integer(
          name: "loan_status_id", 
          label: "Loan Status Id"
        ),
        SimpleFields.integer(
          name: "loan_sub_status_id", 
          label: "Loan Sub Status Id"
        ),
        SimpleFields.integer(
          name: "portfolio_ids", 
          label: "Portfolio IDs"
        ),        
      ]
    elsif event_type == "600"
      [
        SimpleFields.integer(
          name: "custom_field_id_rdn_case_vendor_assigned_name", 
          label: "Custom Field Id RDN Case Vendor Assigned Name"
        ),
        SimpleFields.integer(
          name: "custom_field_id_rdn_case_vendor_assigned_phone", 
          label: "Custom Field Id RDN Case Vendor Assigned Phone"
        ),
        SimpleFields.integer(
          name: "custom_field_id_rdn_case_order_date", 
          label: "Custom Field Id RDN Case Order Date"
        )
      ]
    elsif event_type == "602"
      [
        SimpleFields.integer(
          name: "custom_field_id_rdn_case_closed_reason", 
          label: "Custom Field Id RDN Case Closed Reason"
        ),
        SimpleFields.integer(
          name: "custom_field_id_rdn_case_closed_date", 
          label: "Custom Field Id RDN Case Closed Date"
        ),
      ]
    elsif event_type == "603"
      [
        SimpleFields.integer(
          name: "custom_field_id_rdn_case_hold_date", 
          label: "Custom Field Id RDN Case Hold Date"
        )
      ]
    elsif event_type == "604"
      [
        SimpleFields.integer(
          name: "custom_field_id_rdn_case_closed_reason", 
          label: "Custom Field Id RDN Case Closed Reason"
        ),
        SimpleFields.string(
          name: "close_reason", 
          label: "Close Reason"
        )        
      ]      
    end

    fields || []
  end
end

module RdnActions
  def self.event_types
    {
      title: "RDN Event Type",
      subtitle: "RDN implementation",

      config_fields: [
        {
          name: "event_type",
          label: "Event Type",
          control_type: 'select',
          pick_list: "rdn_event_types",
          optional: false
        }
      ],

      input_fields: lambda do |object_definitions, connection, config_fields|
        note_fields = RdnFields.common_fields
        event_type_fields = RdnFields.event_type_fields(config_fields["event_type"])
      
        event_type_fields + note_fields        
      end,

      execute: lambda do |connection, input|
        payload = {
          "Notes": {
            "results": [
              {
                "subject": "From Ruby sdk",
                "body": "From Ruby sdk Body",
                "categoryId": 4
              }
            ]
          },
          "LoanSettings": {
            "CustomFieldValues": {
              "results": [
                {
                  #"customFieldId" => 3,
                  "customFieldValue" => "New text sdk",
                  '__update': true
                }
              ]
            },
          "__id": 2,
          '__update': true
          },
        }

        #LoanProApiClient.request(
        #  self,
        #  method: :put, 
        #  endpoint: "odata.svc/Loans(#{input['loan_id']})", 
        #  payload: payload
        #)


        params = {"$select": "id,settingsId"}

        LoanProApiClient.request(
          self,
          method: :get, 
          endpoint: "odata.svc/Loans(#{input['loan_id']})?$select=id,settingsId", 
          payload: params
        )


        #settings_id = lp_client.fetch_loan(
        #    loan_id,
        #    params={"$select": "id,settingsId"},
        #)["settingsId"]

      end,

      output_fields: lambda do |object_definitions, connection, config_fields|
        [
          { name: "categoryId", label: "Category Id", type: "integer", optional: false, sticky: true, control_type: 'integer' },
          { name: "subject", label: "Subject", type: "string", optional: false, sticky: true },
          { name: "body", label: "Body", type: "string", optional: false, sticky: true, control_type: 'text_area' },
          { name: "payload", label: "Payload JSON", type: "string", optional: true, control_type: 'text_area' }
        ]
      end
    }
  end
end