  {
    rdn: {
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
          RdnLibrary.rdn_note_fields
      end,

      execute: lambda do |connection, input|
        post("Loans(#{input['loan_id']})/Notes", input['note_section'])
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
  }