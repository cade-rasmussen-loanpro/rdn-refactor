

{
  title: "OFAC Loan Export - SDK",

  connection: {
    fields: [
      {
        name: "aws_account_id",
        label: "AWS Account ID",
        optional: false,
        hint: "12-digit AWS account id. Example: 063712879485"
      },
      {
        name: "aws_region",
        label: "AWS Region",
        optional: false,
        hint: "AWS service region. If your account URL is <b>https://eu-west-1.console.s3.amazon.com</b>, use <b>eu-west-1</b> as the region."
      }
    ],

    authorization: { type: "custom_auth" }
},

  test: lambda { |connection| call(:list_buckets, connection) },

  actions: {
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
  },

  triggers: {
    scheduled_heartbeat: {
      title: "Scheduled heartbeat (polling)",
      subtitle: "Triggers on a schedule",
      description: "Emits an event every time Workato polls this trigger. Use it to run OFAC export on a schedule.",

      input_fields: lambda do |_object_definitions|
        [
          {
            name: "tag",
            label: "Tag (optional)",
            optional: true,
            hint: "Optional label to identify this scheduled trigger instance (e.g. nightly-run)."
          }
        ]
      end,

      poll: lambda do |_connection, input, closure, _eis, _eos|
        closure = {} unless closure.is_a?(Hash)

        occurred_at = Time.now.utc.iso8601
        run_id = "#{(Time.now.to_f * 1000).to_i}-#{rand(100000..999999)}"

        tag = input["tag"].to_s.strip
        tag = nil if tag.empty?

        event = {
          "run_id" => run_id,
          "occurred_at" => occurred_at
        }
        event["tag"] = tag if tag

        {
          events: [event],
          next_poll: { "last_ran_at" => occurred_at },
          can_poll_more: false
        }
      end,

      dedup: lambda do |event|
        event["run_id"]
      end,

      output_fields: lambda do |_object_definitions|
        [
          { name: "run_id" },
          { name: "occurred_at" },
          { name: "tag" }
        ]
      end
    },

    ofac_export_completed_webhook: {
      title: "OFAC export completed (webhook)",
      subtitle: "Triggers when your system POSTs to Workato",
      description: "Use this when your Lambda/API can call the Workato webhook URL.",

      input_fields: lambda do |_object_definitions|
        [
          {
            name: "note",
            label: "Note (optional)",
            optional: true,
            hint: "This is just a label; webhook payload comes from your system."
          }
        ]
      end,

      webhook_subscribe: lambda do |webhook_url, _connection, input|
        note = input["note"].to_s.strip
        note = nil if note.empty?

        sub = { "webhook_url" => webhook_url }
        sub["note"] = note if note
        sub
      end,

      webhook_unsubscribe: lambda do |_subscription|
        true
      end,

      webhook_notification: lambda do |_input, payload, headers, params|
        {
          "payload" => payload,
          "headers" => headers,
          "params" => params
        }
      end,

      dedup: lambda do |event|
        p = event["payload"].is_a?(Hash) ? event["payload"] : {}
        p["id"] || p["job_id"] || p["request_id"] || p["occurred_at"] || event.to_s.hash.to_s
      end,

      output_fields: lambda do |_object_definitions|
        [
          { name: "payload", type: "object" },
          { name: "headers", type: "object" },
          { name: "params", type: "object" }
        ]
      end
    }
},

  pick_lists: {},

  methods: {
    build_assume_role_arn: lambda do |connection|
      account_id = connection["aws_account_id"].to_s.strip
      unless account_id.match?(/\A\d{12}\z/)
        error("Invalid AWS Account ID. Must be 12 digits, got: '#{account_id}'")
      end
      "arn:aws:iam::#{account_id}:role/WorkatoLambdaRole-prod-workato-integrations"
    end,

    build_role_based_connection: lambda do |connection|
      assume_role_arn = call(:build_assume_role_arn, connection)
      connection.merge(
        "aws_auth_type" => "aws_role_based",
        "aws_assume_role" => assume_role_arn
      )
    end,

    list_buckets: lambda do |connection|
      role_conn = call(:build_role_based_connection, connection)

      signature = aws.generate_signature(
        connection: role_conn,
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

    ofac_loan_export: lambda do |connection, input|
      role_conn = call(:build_role_based_connection, connection)

      fn = "prod-ofac-loan-export"
      invocation_type = "Event"

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
        connection: role_conn,
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
}, 
}