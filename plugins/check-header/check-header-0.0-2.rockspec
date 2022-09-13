
package = "check-header"
version = "0.0-2"

local pluginName = "check-header"

source = {
  url = "https://github.com/igstbagusdharmaputra/check-header.git"
}
description = {
  summary = "A Kong plugin, that extract roles from a JWT token and make a request for a Policy Decision Point (PDP)",
  license = "GPL"
}
supported_platforms = {
   "linux",
   "macosx"
}
dependencies = {}
build = {
   type = "builtin",
   modules = {
      ["kong.plugins.check-header.handler"] = "kong/plugins/"..pluginName.."/schema.lua",
      ["kong.plugins.check-header.schema"] = "kong/plugins/"..pluginName.."/handler.lua"
   }
}
