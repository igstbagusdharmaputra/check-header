
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

function table_to_string(tbl)
    local result = ""
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end

        -- Check the value type
        if type(v) == "table" then
            result = result..table_to_string(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        else
            result = result.."\""..v.."\""
        end
        result = result..","
    end
    -- Remove leading commas from the result
    if result ~= "" then
        result = result:sub(1, result:len()-1)
    end
    return result
end

local function array_missing_value(tab, val)
  for index, value in ipairs(tab) do
      if value == val then
          return false
      end
  end
  return true
end

local function add_error(errors, k, v)
  if not errors then
    errors = {}
  end

  if errors and errors[k] then
    if getmetatable(errors[k]) ~= err_list_mt then
      errors[k] = setmetatable({errors[k]}, err_list_mt)
    end

    insert(errors[k], v)
  else
    errors[k] = v
  end

  return errors
end

local function validate_headers(conf)
	local errors

	for header_name,v in pairs(conf.headers) do
		local header_value = kong.request.get_header(header_name)
		if header_value == nil then
			errors = add_error(errors, header_name, "is not present") 
		-- elseif type(id) ~= "string" then
			-- errors = add_error(errors, header_name, "must be a string")
			-- kong.service.request.set_header("x-user-id", id)
		-- return false, { status = 428, message = string.format("Required header '%s' is missing", header_name) }     
		else
			for htype,hvalues in pairs(v) do
				if htype ~= type(header_value) then
					errors = add_error(errors, header_name, string.format("has type %s but expected type was %s", type(header_value), htype)) 
					-- return false, { status = 412, message = string.format("Header '%s' has type: %s. Expected type: %s", header_name, header_type, htype) }
				elseif array_missing_value(hvalues, header_value) then
					-- return false, { status = 412, message = string.format("Invalid value (%s) for header %s", header_value, header_name) }
					errors = add_error(errors, header_name, string.format("has invalid value: %s", header_value)) 
				end
				break
			end
		end
	end
    -- return true
    return errors == nil, errors
end

function HeadersValidationHandler:new()
    HeadersValidationHandler.super.new(self, "headers-validation")
end

function HeadersValidationHandler:access(conf)
    HeadersValidationHandler.super.access(self)

    if kong.request.get_method() == "OPTIONS" then
        return
    end

    local ok, errors = validate_headers(conf)
    if not ok then
		return kong.response.exit(412, { message = "Preconditions failed: " .. table_to_string(errors) })
    end
end


return HeadersValidationHandler