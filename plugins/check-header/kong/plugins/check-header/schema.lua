local typedefs = require "kong.db.schema.typedefs"



return {
    name = "headers-validation",
    fields = {{
        config = {
            type = "record",
            fields = {{
                consumer = typedefs.no_consumer
            }, -- this plugin cannot be configured on a consumer (typical for auth plugins)
            {
              values = {
                type = "record",
                fields = {
                  {
                    values = {
                        type = "array",
                        match_none = {{
                            pattern = "^$",
                            err = "Header expected values cannot be empty"
                        }},
                        elements = {
                            type = "string",
                            required = true
                        }
                    }
                  }
                }
              }
            }}
        }
    }}
}