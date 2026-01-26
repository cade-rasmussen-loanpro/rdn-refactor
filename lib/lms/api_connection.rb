connection: {
    fields: [
      { name: "domain", hint: "loanpro or your PSaaS name." },
      { name: "tenant_id", hint: "Please enter your Tenant ID here." },
      { name: "api_key", hint: "You can find your API key in Settings > Company > API > Overview." }
    ],
    
    authorization: {
      type: "custom_auth",
      apply: lambda do |connection|
        headers("Authorization": "Bearer #{connection['api_key']}")
        headers("Autopal-Instance-ID": connection["tenant_id"])
      end
    },
    
    base_uri: lambda do |connection|
      "https://#{connection['domain']}.simnang.com/api/public/api/1/"
    end
  },

  test: lambda do |connection|
    post("Loans/Autopal.Search()")
  end