module RdnLibrary
  def self.rdn_action_definition
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
        RdnLibrary.input_fields_for_rdn(config_fields)
      end,

      execute: lambda do |connection, input|
        post("Loans(#{input['loan_id']})/Notes", input['note_section'])
      end,

      output_fields: lambda do |object_definitions, connection, config_fields|
        RdnLibrary.output_fields_for_rdn
      end
    }
  end

  def self.input_fields_for_rdn(config_fields)
    [
      { name: "loan_id", label: "Loan ID", type: "integer", optional: false },
      {
        name: "note_section",
        label: "Note Parameters",
        type: "object",
        properties: [
          { name: "category_id", label: "Category Id", type: "integer" },
          { name: "subject", label: "Subject", type: "string" },
          { name: "body", label: "Body", type: "string", control_type: 'text_area' }
        ]
      }
    ]
  end

  def self.output_fields_for_rdn
    [
      { name: "id", label: "Note ID", type: "integer" },
      { name: "subject", label: "Subject", type: "string" }
    ]
  end
end