{
  title: "OFAC Loan Export - SDK 2",

  connection: {
    fields: [
      {
        name: "aws_auth_type",
        label: "AWS Authorization type",
        control_type: "select",
        optional: false,
        pick_list: [
          ["IAM role", "aws_role_based"],
          ["Access key", "aws_key_secret"]
        ],
        default: "aws_role_based",
        hint: 'Learn more about Amazon S3 authorization support <a href="http://docs.workato.com/connectors/s3.html#connection-setup" target="_blank">here</a>.'
      },
      {
        name: "aws_assume_role",
        label: "IAM role ARN",
        optional: false,
        ngIf: 'input.aws_auth_type == "aws_role_based"',
        help: {
          title: "Using IAM Role authorization",
          text: <<~HELP
            Create an IAM role in your AWS account using the following data:
            <br/>&nbsp;- Use Workato AWS Account ID <b>{{ authUser.aws_iam_external_id }}</b>
            to generate the <b>Principal</b> for the role.
            <br/>&nbsp;- Use <b>{{ authUser.aws_workato_account_id }}</b> as the <b>External ID</b> for the role.
            <br/>&nbsp;- Set this field's value to the newly created role's ARN.
            <br/><a href="https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user.html"
            target="_blank">Learn more</a>.
          HELP
        }
      },
      {
        name: "aws_api_key",
        label: "Access key ID",
        control_type: "password",
        optional: false,
        hint: "Go to <b>AWS account name</b> > <b>Security Credentials</b> > <b>Users</b>. Get API key from existing user or create new user.",
        ngIf: 'input.aws_auth_type == "aws_key_secret"'
      },
      {
        name: "aws_secret_key",
        label: "Secret access key",
        control_type: "password",
        optional: false,
        hint: "Go to <b>AWS account name</b> > <b>Security Credentials</b> > <b>Users</b>. Get secret key from existing user or create new user.",
        ngIf: 'input.aws_auth_type == "aws_key_secret"'
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

   methods: {
    list_buckets: lambda do |connection|
      signature = aws.generate_signature(
        # The connection object defined earlier.
        connection: connection,
        # The internal name of the AWS service you are targeting
        service: "s3",
        # The AWS service region you are targeting.
        # For services with a globally unique endpoint such as IAM, use us-east-1.
        region: connection["aws_region"],
        # The host of the API url.
        # Optional and defaults to "#{service}.#{region}.amazonaws.com".
        # In some cases like AWS API Gateway and AWS IAM, your host may not follow this standard and require you to override the host.
        host: "s3.dualstack.#{connection['aws_region']}.amazonaws.com",
        # The relative path of the endpoint. Optional and defaults to "/"
        path: "/",
        # The verb used for the request. Optional and defaults to "GET"
        method: "GET",
        # The query parameters for the request. Optional and defaults to {}
        params: { "list-type" => 2, "max-keys" => 1000 },
        # The headers for the request. Optional and defaults to {}
        headers: {},
        # The payload for the request. Optional and defaults to ""
        payload: ""
      )
      url = signature[:url]
      headers = signature[:headers]

      response = get(url).headers(headers).response_format_xml

      files = response.dig("ListBucketResult", 0, "Contents")
      files = Array.wrap(files).map do |content|
        content.each_with_object({}) do |(k, v), obj|
          obj[k] = Array.wrap(v).dig(0, "content!")
        end
      end

      { "files" => files }
    end
  }
}
