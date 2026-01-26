{
    full_generation: lambda do |connection, input, eis, eos, closure|
      call(:uncompress_file, connection, input, eis, eos, closure)
      call(:fetch_file, connection, input, eis, eos, closure)  
    end,

    uncompress_file: lambda do |connection, input, eis, eos, closure|
      query_object = {
        "query" => {
          "bool" => {
            "must" => [],
            "filter" => {}
          }
        }
      }
      
      post("Customers/Autopal.Search()")
        .payload(query_object)
        .params({
          "$top" => input["$top"] || 25,
          "$start" => input["$start"] || 0,
          "$orderby" => input["$orderby"] || "firstName"
        })
    end,

    fetch_file: lambda do |connection, input, eis, eos, closure|
      query_object = {
        "query" => {
          "bool" => {
            "must" => [],
            "filter" => {}
          }
        }
      }
      
      post("Customers/Autopal.Search()")
        .payload(query_object)
        .params({
          "$top" => input["$top"] || 25,
          "$start" => input["$start"] || 0,
          "$orderby" => input["$orderby"] || "firstName"
        })
    end
  }