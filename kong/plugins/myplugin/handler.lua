-- If you're not sure your plugin is executing, uncomment the line below and restart Kong
-- then it will throw an error which indicates the plugin is being loaded at least.

--assert(ngx.get_phase() == "timer", "The world is coming to an end!")

---------------------------------------------------------------------------------------------
-- In the code below, just remove the opening brackets; `[[` to enable a specific handler
--
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
---------------------------------------------------------------------------------------------



local http = require "resty.http"

local plugin = {
  PRIORITY = 1000, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}



-- do initialization here, any module level code runs in the 'init_by_lua_block',
-- before worker processes are forked. So anything you add here will run once,
-- but be available in all workers.



-- handles more initialization, but AFTER the worker process has been forked/created.
-- It runs in the 'init_worker_by_lua_block'
function plugin:init_worker()

  -- your custom code here
  kong.log.debug("saying hi from the 'init_worker' handler")

end --]]


---[[ Executed every time a plugin config changes.
-- This can run in the `init_worker` or `timer` phase.
-- @param configs table|nil A table with all the plugin configs of this plugin type.
function plugin:configure(configs)
  kong.log.notice("saying hi from the 'configure' handler, got ", (configs and #configs or 0)," configs")

  if configs == nil then
    return -- no configs, nothing to do
  end

  -- your custom code here

end --]]


--[[ runs in the 'ssl_certificate_by_lua_block'
-- IMPORTANT: during the `certificate` phase neither `route`, `service`, nor `consumer`
-- will have been identified, hence this handler will only be executed if the plugin is
-- configured as a global plugin!
function plugin:certificate(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'certificate' handler")

end --]]



--[[ runs in the 'rewrite_by_lua_block'
-- IMPORTANT: during the `rewrite` phase neither `route`, `service`, nor `consumer`
-- will have been identified, hence this handler will only be executed if the plugin is
-- configured as a global plugin!
function plugin:rewrite(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'rewrite' handler")

end --]]



-- runs in the 'access_by_lua_block'
function plugin:access(plugin_conf)
  local req_headers = ngx.req.get_headers()
  local header_value = req_headers[plugin_conf.request_header]

  kong.log.err("checking header ", plugin_conf.request_header, " with value ", header_value)
  if not header_value or header_value == "" then
    return kong.response.exit(plugin_conf.fail_status, plugin_conf.fail_body)
  end

  local httpc = http.new()
  httpc:set_timeout(plugin_conf.timeout)

  local res, err = httpc:request_uri(plugin_conf.check_url, {
    method = plugin_conf.check_method,
    headers = {
      [plugin_conf.request_header] = header_value,
    },
    keepalive = false,
  })

  if not res then
    kong.log.err("check_url request failed: ", err)
    return kong.response.exit(plugin_conf.fail_status, plugin_conf.fail_body)
  end

  if res.status ~= 200 then
    return kong.response.exit(res.status, res.body)
  end

end --]]

--[[ runs in the 'header_filter_by_lua_block'
function plugin:header_filter(plugin_conf)

  -- your custom code here, for example;
  kong.response.set_header(plugin_conf.response_header, "this is on the response")

end --]]


--[[ runs in the 'body_filter_by_lua_block'
function plugin:body_filter(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'body_filter' handler")

end --]]


--[[ runs in the 'log_by_lua_block'
function plugin:log(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'log' handler")

end --]]


-- return our plugin object
return plugin
