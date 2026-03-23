local typedefs = require "kong.db.schema.typedefs"


local PLUGIN_NAME = "myplugin"


local schema = {
  name = PLUGIN_NAME,
  fields = {
    -- the 'fields' array is the top-level entry with fields defined by Kong
    { consumer = typedefs.no_consumer },  -- this plugin cannot be configured on a consumer (typical for auth plugins)
    { protocols = typedefs.protocols_http },
    { config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
          -- a standard defined field (typedef), with some customizations
          { request_header = typedefs.header_name {
              required = true,
              default = "Hello-World" } },
          { request_header_value = {
             type = "string",
             required = true,
             default = "bad request" } },

          { response_header = typedefs.header_name {
              required = true,
              default = "Bye-World" } },
          { ttl = { -- self defined field
              type = "integer",
              default = 600,
              required = true,
              gt = 0, }}, -- adding a constraint for the value
          { check_url = { type = "string", required = true, default = "http://httpbin.org/get" } },
          { check_method = { type = "string", required = true, default = "GET", one_of = { "GET", "HEAD", "POST", "PUT", "DELETE", "PATCH", "OPTIONS" } } },
          { timeout = { type = "integer", required = true, default = 5000, gt = 0 } },
          { fail_status = { type = "integer", required = true, default = 403, gt = 100 } },
          { fail_body = { type = "string", required = true, default = "access denied" } },
        },
      },
    },
  },
}

return schema
