{
    ofac_loan_export: {
      description: "Ofac Loan Export",

      input_fields: lambda do |_object_definitions|
        [
          {
            name: "tenant_id",
            label: "LoanPro Tenant ID",
            optional: false,
            sticky: true,
            hint: "Identifies the specific LoanPro tenant where OFAC screening and portfolio updates will be performed."
          },
          {
            name: "loanpro_api_key",
            label: "LoanPro API Key",
            control_type: "password",
            optional: false,
            sticky: true,
            hint: "API key used to authenticate requests to the LoanPro Public API for this tenant."
          },
          {
            name: "ofac_positive_portfolio_id",
            label: "OFAC Positive Portfolio ID",
            optional: false,
            sticky: true,
            hint: "Portfolio ID that is automatically added to a loan when BaseLayer returns a positive OFAC match."
          },
          {
            name: "ofac_check_portfolio_id",
            label: "OFAC Check Portfolio ID",
            optional: false,
            sticky: true,
            hint: "Portfolio ID used to flag loans that need to be sent to BaseLayer for OFAC screening."
          },
          {
            name: "ofac_last_updated_cf_id",
            label: "OFAC Last Checked Custom Field ID (Customer-level)",
            optional: false,
            sticky: true,
            hint: "Custom field ID that stores the date when the customer was last screened by BaseLayer."
          },
          {
            name: "ofac_note_category_id",
            label: "OFAC Note Category ID",
            optional: false,
            sticky: true,
            hint: "Note category used when logging OFAC screening results or BaseLayer responses on a loan."
          },
          {
            name: "ofac_loan_status_option_id",
            label: "OFAC Loan Status Option ID",
            optional: false,
            sticky: true,
            hint: "Option ID for a select-type loan status custom field, used to reflect the OFAC screening outcome."
          },
          {
            name: "ofac_loan_sub_status",
            label: "Loan Sub-Status (such as open - repaying)",
            optional: false,
            sticky: true,
            hint: "Specifies the loan sub-status required for loans to be eligible for OFAC screening."
          },
          {
            name: "ofac_status_cf_id",
            label: "OFAC Result Status Custom Field ID",
            optional: false,
            sticky: true,
            hint: "Custom field ID of select type that stores the final BaseLayer OFAC result, such as: Positive, Negative, False Positive."
          }
        ]
      end,

      execute: lambda do |connection, input|
        call(:ofac_loan_export, connection, input)
      end,

      output_fields: lambda do |_object_definitions|
        [
          { name: "status_code" },
          { name: "request_id" },
          { name: "executed_version" },
          { name: "response_body" }
        ]
      end
    }
  }