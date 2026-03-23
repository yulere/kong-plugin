# kong-plugin
  This is a plugin based on kong/kong-plugin.
  This plugin is to send the client request to a AUTH server first with the required header, and if the AUTH server return 200 then it can continue proxying per kong gateway, otherwise reject the client request.

# workflow
  [schema.lua](./kong/plugins/myplugin/schema.lua)
    define AUTH server url request header for handler.lua (to be checked on AUTH server)

  [handler.lua](./kong/plugins/myplugin/handler.lua)
    redirect any request to AUTH server first, check the response,  continue proxying for 200 response and reject for others.

  [spec/myplugin](./spec/myplugin/)
    define the testcases which include unit-test and functional test.

# Test Result [./test/pongo.txt](./test/pongo.txt):

# Test Summary:
[==========] 9 tests from 2 test files ran. (29328.85 ms total)
[  PASSED  ] 6 tests.
[  FAILED  ] 3 tests, listed below:
[  FAILED  ] /kong-plugin/spec/myplugin/02-unit_spec.lua:75: myplugin: (unit) rejects when check_url returns non-200
[  FAILED  ] /kong-plugin/spec/myplugin/10-integration_spec.lua:74: myplugin: (access) [#postgres] wrong header gets an invalid 'Hello-World' header
[  FAILED  ] /kong-plugin/spec/myplugin/10-integration_spec.lua:74: myplugin: (access) [#off] wrong header gets an invalid 'Hello-World' header

 3 FAILED TESTS

# Failed Reason:
1. 10-integration_spec.lua:74  now we use httpbin.org and I don't find a way to check the header, so it only return 200. So for invalide request, I also get 200(should be 4xx), and the test failed.
2. 02-unit_spec.lua:75 I think there is a mock function to simulate request_uri return 401, but seems simualation not working. 
