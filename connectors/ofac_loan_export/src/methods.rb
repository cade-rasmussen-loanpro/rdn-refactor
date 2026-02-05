{
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
}