local type = type
local error = error
local insert = table.insert
local tostring = tostring
local setmetatable = setmetatable
local getmetatable = getmetatable

local plugin = {
  PRIORITY = 1000, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}


local err_list_mt = {}

local function array_missing_value(tab, val)
  for index, value in ipairs(tab) do
      if value == val then
          return false
      end
  end
  return true
end

local function create_error(errors, header_name, error_message, error_code)
  return {
      header_name = header_name,
      error_message = error_message,
      error_code = error_code
  }
end

local function validate_headers(plugin_conf)
  local error = nil
  for header_name, header_config in pairs(plugin_conf.headers) do
      if header_config.http_methods[kong.request.get_method()] then
          local header_value = kong.request.get_header(header_name)
          if header_value == nil and header_config.required then
              error = create_error(header_name, header_config.missing_header_response_text,
                  header_config.missing_header_response_code)
          else
              if array_missing_value(header_config.values, header_value) then
                  error = create_error(header_name, header_config.invalid_header_response_text,
                      header_config.invalid_header_response_code)
              end
          end
      end
  end
  return error
end


function plugin:init_worker()
  -- your custom code here
  kong.log.debug("saying hi from the 'init_worker' handler")

end --]]


-- runs in the 'access_by_lua_block'
function plugin:access(plugin_conf)
  local ok, errors = validate_headers(plugin_conf)

  if kong.request.get_method() == "OPTIONS" then
    return
  end
  if not ok then
    return kong.response.exit(412, { message = "Preconditions failed: " .. table_to_string(errors) })
  end
  -- your custom code here
  kong.log.inspect(plugin_conf)   -- check the logs for a pretty-printed config!
  kong.service.request.set_header(plugin_conf.request_header, "this is on a request")

end --]]


-- runs in the 'header_filter_by_lua_block'
function plugin:header_filter(plugin_conf)

  -- your custom code here, for example;
  kong.response.set_header(plugin_conf.response_header, "this is on the response")

end --]]

return plugin