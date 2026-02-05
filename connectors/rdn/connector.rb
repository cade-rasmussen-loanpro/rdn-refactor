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

{
  title: "RDN Connector SDK",

  connection:   {
    fields: [
      { 
        name: "domain", 
        label: "Domain",
        hint: "loanpro or your PSaaS name.",
        optional: false 
      },
      { 
        name: "tenant_id", 
        label: "Tenant ID",
        hint: "Please enter your Tenant ID here.",
        optional: false 
      },
      { 
        name: "api_key", 
        label: "API Key",
        hint: "You can find your API key in Settings > Company > API > Overview.",
        control_type: "password",
        optional: false 
      }
    ],
    
    authorization: {
      type: "custom_auth",
      apply: lambda do |connection|
        headers("Authorization": "Bearer #{connection['api_key']}")
        headers("Autopal-Instance-ID": connection["tenant_id"].to_s)
      end
    },
    
    base_uri: lambda do |connection|
      "https://#{connection['domain']}.simnang.com/api/public/api/1/"
    end
  },

  test: lambda { |connection| post('Loans/Autopal.Search()?$top=1') },

  actions:   {
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
  },

  triggers: {},

  pick_lists:   {
    rdn_event_types: lambda do
      [
        ["100", "100"],
        ["101", "101"],
        ["200", "200"],
        ["300", "300"],
        ["301", "301"],
        ["601", "601"],
      ]
    end
  },

  methods: {}, 
}