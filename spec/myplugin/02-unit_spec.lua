-- local helpers = require "spec.helpers"

local PLUGIN_NAME = "myplugin"



describe(PLUGIN_NAME .. ": (unit)", function()

  local plugin
  local exit_status, exit_body
  local check_requests


  setup(function()
    _G.kong = {
      log = { err = function() end },
      response = {
        exit = function(status, body)
          exit_status = status
          exit_body = body
        end,
      },
    }

    package.loaded["resty.http"] = {
      new = function()
        return {
          set_timeout = function() end,
          request_uri = function(_, _)
            return { status = 200 }
          end,
        }
      end,
    }

    plugin = require("kong.plugins." .. PLUGIN_NAME .. ".handler")
  end)


  before_each(function()
    exit_status = nil
    exit_body = nil
    check_requests = {}
    ngx.req.get_headers = function()
      return { ["Hello-World"] = "valid request" }
    end
  end)


  local conf = {
    check_url = "http://httpbin.org/get",
    check_method = "GET",
    request_header = "Hello-World",
    timeout = 5000,
    fail_status = 403,
    fail_body = "access denied",
  }


  it("continues when check_url returns 200", function()

    plugin:access(conf)
    assert.is_nil(exit_status)
    assert.is_nil(exit_body)
  end)

  it("rejects when header missing", function()
    ngx.req.get_headers = function() return {} end

    plugin:access(conf)
    assert.equal(403, exit_status)
    assert.equal("access denied", exit_body)
  end)

  it("rejects when check_url returns non-200", function()
    package.loaded["resty.http"] = {
      new = function()
        return {
          set_timeout = function() end,
          request_uri = function(_, _)
            return { status = 401 }
          end,
        }
      end,
    }

    plugin:access(conf)
    assert.equal(401, exit_status)
    assert.equal("access denied", exit_body)
  end)

end)
