local BasePlugin = require "kong.plugins.base_plugin"

local type = type
local error = error
local insert = table.insert
local tostring = tostring
local setmetatable = setmetatable
local getmetatable = getmetatable

local HeadersValidationHandler = BasePlugin:extend()
HeadersValidationHandler.PRIORITY = 100

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

local function validate_headers(conf)
    local error = nil
    for header_name, header_config in pairs(conf.headers) do
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

function HeadersValidationHandler:new()
    HeadersValidationHandler.super.new(self, "check-header")
end

function HeadersValidationHandler:access(conf)
    HeadersValidationHandler.super.access(self)

    if kong.request.get_method() == "OPTIONS" then
        return
    end

    local error = validate_headers(conf)
    if not error == nil then
        return kong.response.exit(error.code, {
            message = error.message
        })
    end
end

return HeadersValidationHandler