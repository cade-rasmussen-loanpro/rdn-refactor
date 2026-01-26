{
  title: 'Lms Credit Report',

  connection: {
    fields: [
      {
        name: "domain",
        hint: "\"loanpro\" or your PSaaS name."
      },
      {
        name: "tenant_id",
        hint: "Please enter your Tenant ID here."
      },
      {
        name: "api_key",
        hint: "You can find your API key in Settings > Company > API > Overview."
      }
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
  end,

  actions: {
    create_report: {
      title: "Create Report",
      subtitle: "Create Report",
      description: "",

      input_fields: lambda do
        [
          {
            name: "file_contents",
            label: "File Contents",
            optional: false,
            sticky: true
          }
        ]
      end,

      execute: lambda do |connection, input, eis, eos, closure|       
        query_object = {
           "query" => {
             "bool" => {
               "must" => [],
               "filter" => {}
             }
           }
         }
        
        #  query_object["query"]["bool"]["must"] << { "match" => { "firstName" => input["firstName"] } } if input["firstName"]
        
        
         post("Customers/Autopal.Search()")
         .payload(query_object)
         .params({
           "$top" => input["$top"] || 25,  # Default to 25 if not provided
           "$start" => input["$start"] || 0,  # Default to 0 if not provided
           "$orderby" => input["$orderby"] || "firstName"
         })
      end,

       output_fields: lambda do
         [
           {
             name: "Customers",
             type: "array",
             of: "object",
             properties: [
               { name: "lastName", label: "Last Name", type: "string" },
               { name: "hasEmployer", label: "Has Employer", type: "integer" },
               { name: "gender", label: "Gender", type: "string" },
               { name: "loansCount", label: "Loans Count", type: "integer" },
               { name: "customFields", label: "Custom Fields", type: "object" },
               { name: "dynamicProperties", label: "Dynamic Properties", type: "array", of: "object" },
               { name: "companyName", label: "Company Name", type: "string" },
               { name: "primaryPhoneDnd", label: "Primary Phone DND", type: "string" },
               { name: "customId", label: "Custom ID", type: "string" },
               { name: "ssn", label: "SSN", type: "string" },
               { name: "customerType", label: "Customer Type", type: "string" },
               { name: "paymentAccountsCount", label: "Payment Accounts Count", type: "integer" },
               { name: "customerId", label: "Customer ID", type: "string" },
               { name: "creditLimit", label: "Credit Limit", type: "string" },
               { name: "employer", label: "Employer", type: "string" },
               { name: "id", label: "ID", type: "string" },
               { name: "email", label: "Email", type: "string" },
               { name: "creditScore", label: "Credit Score", type: "integer" },
               { name: "referencesCount", label: "References Count", type: "integer" },
               { name: "contactName", label: "Contact Name", type: "string" },
               { name: "created", label: "Created Date", type: "string" },
               { name: "ofacCompliance", label: "OFAC Compliance", type: "string" },
               { name: "birthDate", label: "Birth Date", type: "string" },
               { name: "customerName", label: "Customer Name", type: "string" },
               { name: "hasAvatar", label: "Has Avatar", type: "string" },
               { name: "firstName", label: "First Name", type: "string" },
               { name: "primaryPhone", label: "Primary Phone", type: "string" },
               { name: "ofactTested", label: "OFAC Tested", type: "string" },
               { name: "smsVerified", label: "SMS Verified", type: "integer" },
               { name: "middleName", label: "Middle Name", type: "string" },
               { name: "saleTransferPii", label: "Sale Transfer PII", type: "integer" },
               { name: "accessUsername", label: "Access Username", type: "string" },
               {
                 name: "primaryAddress",
                 label: "Primary Address",
                 type: "object",
                 properties: [
                   { name: "zipcode", label: "Zip Code", type: "string" },
                   { name: "country", label: "Country", type: "string" },
                   { name: "isVerified", label: "Address Verified", type: "string" },
                   { name: "city", label: "City", type: "string" },
                   { name: "address1", label: "Address Line 1", type: "string" },
                   { name: "state", label: "State", type: "string" }
                 ]
               },
               { name: "ofactMatch", label: "OFAC Match", type: "string" },
               { name: "age", label: "Age", type: "integer" },
               { name: "status", label: "Status", type: "string" }
             ]
           }
         ]
      end
     },

    fetch_file: {
      title: "Fech File",
      subtitle: "Fech File",
      description: "",

      input_fields: lambda do
        [
          {
            name: "file_name",
            label: "File Name",
            optional: false,
            sticky: true
          }
        ]
      end,

      execute: lambda do |connection, input, eis, eos, closure|       
        query_object = {
           "query" => {
             "bool" => {
               "must" => [],
               "filter" => {}
             }
           }
         }
        
        #  query_object["query"]["bool"]["must"] << { "match" => { "firstName" => input["firstName"] } } if input["firstName"]
        
        
         post("Customers/Autopal.Search()")
         .payload(query_object)
         .params({
           "$top" => input["$top"] || 25,  # Default to 25 if not provided
           "$start" => input["$start"] || 0,  # Default to 0 if not provided
           "$orderby" => input["$orderby"] || "firstName"
         })
      end,

       output_fields: lambda do
         [
           {
             name: "Customers",
             type: "array",
             of: "object",
             properties: [
               { name: "lastName", label: "Last Name", type: "string" },
               { name: "hasEmployer", label: "Has Employer", type: "integer" },
               { name: "gender", label: "Gender", type: "string" },
               { name: "loansCount", label: "Loans Count", type: "integer" },
               { name: "customFields", label: "Custom Fields", type: "object" },
               { name: "dynamicProperties", label: "Dynamic Properties", type: "array", of: "object" },
               { name: "companyName", label: "Company Name", type: "string" },
               { name: "primaryPhoneDnd", label: "Primary Phone DND", type: "string" },
               { name: "customId", label: "Custom ID", type: "string" },
               { name: "ssn", label: "SSN", type: "string" },
               { name: "customerType", label: "Customer Type", type: "string" },
               { name: "paymentAccountsCount", label: "Payment Accounts Count", type: "integer" },
               { name: "customerId", label: "Customer ID", type: "string" },
               { name: "creditLimit", label: "Credit Limit", type: "string" },
               { name: "employer", label: "Employer", type: "string" },
               { name: "id", label: "ID", type: "string" },
               { name: "email", label: "Email", type: "string" },
               { name: "creditScore", label: "Credit Score", type: "integer" },
               { name: "referencesCount", label: "References Count", type: "integer" },
               { name: "contactName", label: "Contact Name", type: "string" },
               { name: "created", label: "Created Date", type: "string" },
               { name: "ofacCompliance", label: "OFAC Compliance", type: "string" },
               { name: "birthDate", label: "Birth Date", type: "string" },
               { name: "customerName", label: "Customer Name", type: "string" },
               { name: "hasAvatar", label: "Has Avatar", type: "string" },
               { name: "firstName", label: "First Name", type: "string" },
               { name: "primaryPhone", label: "Primary Phone", type: "string" },
               { name: "ofactTested", label: "OFAC Tested", type: "string" },
               { name: "smsVerified", label: "SMS Verified", type: "integer" },
               { name: "middleName", label: "Middle Name", type: "string" },
               { name: "saleTransferPii", label: "Sale Transfer PII", type: "integer" },
               { name: "accessUsername", label: "Access Username", type: "string" },
               {
                 name: "primaryAddress",
                 label: "Primary Address",
                 type: "object",
                 properties: [
                   { name: "zipcode", label: "Zip Code", type: "string" },
                   { name: "country", label: "Country", type: "string" },
                   { name: "isVerified", label: "Address Verified", type: "string" },
                   { name: "city", label: "City", type: "string" },
                   { name: "address1", label: "Address Line 1", type: "string" },
                   { name: "state", label: "State", type: "string" }
                 ]
               },
               { name: "ofactMatch", label: "OFAC Match", type: "string" },
               { name: "age", label: "Age", type: "integer" },
               { name: "status", label: "Status", type: "string" }
             ]
           }
         ]
      end
     },     

    uncompress_file: {
      title: "Uncompress File",
      subtitle: "Uncompress File",
      description: "",

      input_fields: lambda do
        [
          {
            name: "file_name",
            label: "File Name",
            optional: false,
            sticky: true
          }
        ]
      end,

      execute: lambda do |connection, input, eis, eos, closure|       
        query_object = {
           "query" => {
             "bool" => {
               "must" => [],
               "filter" => {}
             }
           }
         }
        
        #  query_object["query"]["bool"]["must"] << { "match" => { "firstName" => input["firstName"] } } if input["firstName"]
        
        
         post("Customers/Autopal.Search()")
         .payload(query_object)
         .params({
           "$top" => input["$top"] || 25,  # Default to 25 if not provided
           "$start" => input["$start"] || 0,  # Default to 0 if not provided
           "$orderby" => input["$orderby"] || "firstName"
         })
      end,

       output_fields: lambda do
         [
           {
             name: "Customers",
             type: "array",
             of: "object",
             properties: [
               { name: "lastName", label: "Last Name", type: "string" },
               { name: "hasEmployer", label: "Has Employer", type: "integer" },
               { name: "gender", label: "Gender", type: "string" },
               { name: "loansCount", label: "Loans Count", type: "integer" },
               { name: "customFields", label: "Custom Fields", type: "object" },
               { name: "dynamicProperties", label: "Dynamic Properties", type: "array", of: "object" },
               { name: "companyName", label: "Company Name", type: "string" },
               { name: "primaryPhoneDnd", label: "Primary Phone DND", type: "string" },
               { name: "customId", label: "Custom ID", type: "string" },
               { name: "ssn", label: "SSN", type: "string" },
               { name: "customerType", label: "Customer Type", type: "string" },
               { name: "paymentAccountsCount", label: "Payment Accounts Count", type: "integer" },
               { name: "customerId", label: "Customer ID", type: "string" },
               { name: "creditLimit", label: "Credit Limit", type: "string" },
               { name: "employer", label: "Employer", type: "string" },
               { name: "id", label: "ID", type: "string" },
               { name: "email", label: "Email", type: "string" },
               { name: "creditScore", label: "Credit Score", type: "integer" },
               { name: "referencesCount", label: "References Count", type: "integer" },
               { name: "contactName", label: "Contact Name", type: "string" },
               { name: "created", label: "Created Date", type: "string" },
               { name: "ofacCompliance", label: "OFAC Compliance", type: "string" },
               { name: "birthDate", label: "Birth Date", type: "string" },
               { name: "customerName", label: "Customer Name", type: "string" },
               { name: "hasAvatar", label: "Has Avatar", type: "string" },
               { name: "firstName", label: "First Name", type: "string" },
               { name: "primaryPhone", label: "Primary Phone", type: "string" },
               { name: "ofactTested", label: "OFAC Tested", type: "string" },
               { name: "smsVerified", label: "SMS Verified", type: "integer" },
               { name: "middleName", label: "Middle Name", type: "string" },
               { name: "saleTransferPii", label: "Sale Transfer PII", type: "integer" },
               { name: "accessUsername", label: "Access Username", type: "string" },
               {
                 name: "primaryAddress",
                 label: "Primary Address",
                 type: "object",
                 properties: [
                   { name: "zipcode", label: "Zip Code", type: "string" },
                   { name: "country", label: "Country", type: "string" },
                   { name: "isVerified", label: "Address Verified", type: "string" },
                   { name: "city", label: "City", type: "string" },
                   { name: "address1", label: "Address Line 1", type: "string" },
                   { name: "state", label: "State", type: "string" }
                 ]
               },
               { name: "ofactMatch", label: "OFAC Match", type: "string" },
               { name: "age", label: "Age", type: "integer" },
               { name: "status", label: "Status", type: "string" }
             ]
           }
         ]
      end
     },

  },

  triggers: {

daily_google_check: {
  title: "Daily Google Check",
  description: "Runs at specified time and fetches Google homepage",
  
  input_fields: lambda do
    [
      {
        name: "schedule_hour",
        label: "Hour (0-23)",
        type: "integer",
        control_type: "number",
        optional: false,
        hint: "Hour in 24-hour format (e.g., 8 for 8 AM, 14 for 2 PM)"
      },
      {
        name: "schedule_minute",
        label: "Minute (0-59)",
        type: "integer",
        control_type: "number",
        optional: true,
        default: 0,
        hint: "Minute of the hour (default: 0)"
      },
      {
        name: "days_of_week",
        label: "Days of Week",
        type: "string",
        control_type: "multiselect",
        pick_list: [
          ["Monday", "1"],
          ["Tuesday", "2"],
          ["Wednesday", "3"],
          ["Thursday", "4"],
          ["Friday", "5"],
          ["Saturday", "6"],
          ["Sunday", "0"]
        ],
        optional: true,
        hint: "Leave empty to run every day"
      }
    ]
  end,
  
  poll: lambda do |connection, input, last_updated_since|
    current_time = Time.now
    schedule_hour = input["schedule_hour"]
    schedule_minute = input["schedule_minute"] || 0
    
    # Verificar si es el día correcto (si se especificó)
    day_match = if input["days_of_week"].present?
      input["days_of_week"].include?(current_time.wday.to_s)
    else
      true
    end
    
    # Verificar si es la hora correcta
    time_match = current_time.hour == schedule_hour && current_time.min >= schedule_minute
    
    # Verificar si ya se ejecutó hoy
    already_ran_today = last_updated_since && 
                        Time.parse(last_updated_since).to_date == current_time.to_date
    
    if day_match && time_match && !already_ran_today
      response = get("https://www.google.com")
      
      {
        events: [{
          timestamp: current_time.iso8601,
          status: "success",
          scheduled_time: "#{schedule_hour}:#{schedule_minute.to_s.rjust(2, '0')}",
          content_length: response.length
        }],
        next_poll: current_time.iso8601
      }
    else
      {
        events: [],
        next_poll: last_updated_since || current_time.iso8601
      }
    end
  end,
  
  output_fields: lambda do
    [
      { name: "timestamp", type: "date_time" },
      { name: "status", type: "string" },
      { name: "scheduled_time", type: "string" },
      { name: "content_length", type: "integer" }
    ]
  end
},
  

    file_availability_check: {
      title: "Check File Availability After 8 AM",
      description: "Continuously checks if a file exists at the specified URL after 8 AM",
      
      input_fields: lambda do
        [
          { name: "file_name", label: "File Name to Check", optional: false }
        ]
      end,
      
      poll: lambda do |connection, input, last_updated_since|
        current_time = Time.now
        
        # Solo ejecutar después de las 8 AM
        if current_time.hour >= 8
          file_url = "#{connection['file_check_url']}/#{input['file_name']}"
          
          begin
            response = get(file_url)
            
            # Si el archivo existe, disparar el evento
            {
              events: [{
                file_name: input["file_name"],
                file_url: file_url,
                found_at: current_time.iso8601,
                status: "found",
                file_size: response.length
              }],
              next_poll: current_time.iso8601,
              can_poll_more: false  # Detener polling después de encontrar el archivo
            }
          rescue
            # Si el archivo no existe, seguir consultando
            {
              events: [],
              next_poll: current_time.iso8601,
              can_poll_more: true  # Continuar polling cada 5 minutos
            }
          end
        else
          # Antes de las 8 AM, no hacer nada
          {
            events: [],
            next_poll: last_updated_since || current_time.iso8601,
            can_poll_more: false
          }
        end
      end,
      
      output_fields: lambda do
        [
          { name: "file_name", type: "string" },
          { name: "file_url", type: "string" },
          { name: "found_at", type: "date_time" },
          { name: "status", type: "string" },
          { name: "file_size", type: "integer" }
        ]
      end
    }



  },

  methods: {

  },

  object_definitions: {

  },

  pick_lists: {

  }
}
