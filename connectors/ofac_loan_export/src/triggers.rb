{
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
}