local typedefs = require "kong.db.schema.typedefs"


return {
  name = "headers-validation",
  fields = {
    { config = {
        type = "record",
        fields = {
          { consumer = typedefs.no_consumer },  -- this plugin cannot be configured on a consumer (typical for auth plugins)
          {
            headers = {
                type = "map",
                keys = { type = "string", match_none = { {pattern = "^$", err = "Header name cannot be empty",}, }, },
                values = {
                    type = "map",
                    match_none = { {pattern = "^$",err = "Header expected type and possible values (map) cannot be empty",}, },
                    keys = { type = "string", match_none = { {pattern = "^$",err = "Header type (string or number) cannot be empty",}, }, },
                    values = { 
                      type = "array", 
                      match_none = { {pattern = "^$",err = "Header expected values cannot be empty",}, },
                      elements = { type = "string", required = true },
                    },
                },
                default = {}
            },
         },
        },
      },
    },
  },
}