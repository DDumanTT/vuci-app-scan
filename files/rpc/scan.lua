local rpc = require "vuci.rpc"

local M = {}

function M.scan(params)
    io.popen("scan -n " .. params.network)
    return {msg="success"}
end

function M.get()
    file = io.open("/tmp/lua-shell-cmd-out")
    return {result=file:read("*all")}
end

return M