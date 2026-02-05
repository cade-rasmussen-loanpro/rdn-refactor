{
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
}