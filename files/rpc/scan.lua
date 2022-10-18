local rpc = require("vuci.rpc")
local json = require("json")

local M = {}

function M.scan(params)
    local file = io.open("/tmp/lua-shell-cmd-out", "w")
    if not file then
        return {msg="failed"}
    end
    file:write(json.encode({status="running"}))
    file:close()
    
    io.popen("scan -n " .. params.network)
    return {msg="success"}
end

function M.get()
    local file = io.open("/tmp/lua-shell-cmd-out")
    if not file then
        return {result="failed"}
    end
    local result = file:read("*all")
    file:close()
    return {result=result}
end

return M