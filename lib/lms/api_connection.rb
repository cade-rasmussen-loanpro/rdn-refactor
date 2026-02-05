  {
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
  }