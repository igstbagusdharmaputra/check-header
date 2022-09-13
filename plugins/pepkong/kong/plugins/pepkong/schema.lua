local typedefs = require "kong.db.schema.typedefs"

http_method = Schema.define {
    type = "string",
    match = "^(GET|HEAD|POST|PUT|DELETE|CONNECT|OPTIONS|TRACE|PATCH)$"
}

http_methods = Schema.define {
    type = "set",
    elements = http_method
}

return {
    name = "headers-validation",
    fields = {{
        config = {
            type = "record",
            fields = {{
                consumer = typedefs.no_consumer
            }, -- this plugin cannot be configured on a consumer (typical for auth plugins)
            {
                rules = {
                    type = "map",
                    keys = {
                        type = "string",
                        match_none = {{
                            pattern = "^$",
                            err = "Rule name cannot be empty"
                        }}
                    },
                    values = {
                        type = "record",
                        fields = {{
                            http_methods = {
                                type = "set",
                                required = true,
                                default = "*",
                                elements = {
                                    type = "string",
                                    one_of = http_methods
                                }
                            }
                        }, {
                            invalid_header_response_code = {
                                type = "integer",
                                between = {100, 600},
                                default = 400
                            }
                        }, {
                            invalid_header_response_text = {
                                type = "string",
                                default = ""
                            }
                        }, {
                            missing_header_response_code = {
                                type = "integer",
                                between = {100, 600},
                                default = 400
                            }
                        }, {
                            missing_header_response_text = {
                                type = "string",
                                default = ""
                            }
                        }, {
                            required = {
                                type = "boolean",
                                default = false
                            }
                        }, {
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
                        }}
                    }
                }
            }}
        }
    }}
}