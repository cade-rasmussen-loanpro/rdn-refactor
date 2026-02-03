{
  title: "OFAC Loan Export - SDK",

  connection: {
    fields: [
      {
        name: "aws_auth_type",
        label: "AWS Authorization type",
        control_type: "select",
        optional: false,
        pick_list: [
          ["IAM role", "aws_role_based"]
        ],
        default: "aws_role_based"
      },
      {
        name: "aws_assume_role",
        label: "IAM role ARN",
        optional: false,
        ngIf: 'input.aws_auth_type == "aws_role_based"',
        help: {
          title: "Using IAM Role authorization"
        }
      },
      {
        name: "aws_region",
        optional: false,
        hint: "AWS service region. If your account URL is <b>https://eu-west-1.console.s3.amazon.com</b>, use <b>eu-west-1</b> as the region."
      }
    ],
    authorization: {
      type: "custom_auth"
    }
  },

  test: lambda do |connection|
    call(:list_buckets, connection)
  end,

  actions: {
    invoke_lambda: {
      description: "Ofac Loan Export",

      input_fields: lambda do |_object_definitions|
        [
          { name: "function_name_or_arn", label: "Lambda function name or ARN", optional: false },

          # --- Payload fields (each as an input) ---
          { name: "tenant_id", label: "Tenant ID", optional: false, sticky: true },
          { name: "loanpro_api_key", label: "LoanPro API Key", control_type: "password", optional: false, sticky: true },

          { name: "ofac_positive_portfolio_id", label: "OFAC Positive Portfolio ID", optional: false, sticky: true },
          { name: "ofac_check_portfolio_id", label: "OFAC Check Portfolio ID", optional: false, sticky: true },

          { name: "ofac_last_updated_cf_id", label: "OFAC Last Updated CF ID", optional: false, sticky: true },
          { name: "ofac_note_category_id", label: "OFAC Note Category ID", optional: false, sticky: true },

          { name: "ofac_loan_status_option_id", label: "OFAC Loan Status Option ID", optional: false, sticky: true },
          { name: "ofac_loan_sub_status", label: "OFAC Loan Sub Status", optional: false, sticky: true },

          { name: "ofac_status_cf_id", label: "OFAC Status CF ID", optional: false, sticky: true }
        ]
      end,

      execute: lambda do |connection, input|
        call(:invoke_lambda, connection, input)
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
  },

  methods: {
    list_buckets: lambda do |connection|
      signature = aws.generate_signature(
        connection: connection,
        service: "s3",
        region: connection["aws_region"],
        host: "s3.dualstack.#{connection['aws_region']}.amazonaws.com",
        path: "/",
        method: "GET",
        params: { "list-type" => 2, "max-keys" => 1000 },
        headers: {},
        payload: ""
      )

      response = get(signature[:url])
        .headers(signature[:headers])
        .response_format_xml

      files = response.dig("ListBucketResult", 0, "Contents")
      files = Array.wrap(files).map do |content|
        content.each_with_object({}) do |(k, v), obj|
          obj[k] = Array.wrap(v).dig(0, "content!")
        end
      end

      { "files" => files }
    end,

    invoke_lambda: lambda do |connection, input|
      fn = input["function_name_or_arn"]

      # 🔒 Hidden from UI: always async
      invocation_type = "Event"

      # Build payload EXACTLY with the keys you provided
      payload_hash = {
        "tenant_id" => input["tenant_id"].to_s,
        "loanpro_api_key" => input["loanpro_api_key"].to_s,
        "ofac_positive_portfolio_id" => input["ofac_positive_portfolio_id"].to_s,
        "ofac_check_portfolio_id" => input["ofac_check_portfolio_id"].to_s,
        "ofac_last_updated_cf_id" => input["ofac_last_updated_cf_id"].to_s,
        "ofac_note_category_id" => input["ofac_note_category_id"].to_s,
        "ofac_loan_status_option_id" => input["ofac_loan_status_option_id"].to_s,
        "ofac_loan_sub_status" => input["ofac_loan_sub_status"].to_s,
        "ofac_status_cf_id" => input["ofac_status_cf_id"].to_s
      }

      payload = payload_hash.to_json

      signature = aws.generate_signature(
        connection: connection,
        service: "lambda",
        region: connection["aws_region"],
        host: "lambda.#{connection['aws_region']}.amazonaws.com",
        path: "/2015-03-31/functions/#{fn}/invocations",
        method: "POST",
        headers: {
          "Content-Type" => "application/json",
          "x-amz-invocation-type" => invocation_type
        },
        payload: payload
      )

      resp = post(signature[:url])
        .headers(signature[:headers])
        .request_body(payload)

      {
        "status_code" => (resp.status rescue nil),
        "request_id" => (resp.headers["x-amzn-RequestId"] rescue nil),
        "executed_version" => (resp.headers["x-amz-executed-version"] rescue nil),
        "response_body" => (resp.response_body rescue resp)
      }
    end
  }
}
