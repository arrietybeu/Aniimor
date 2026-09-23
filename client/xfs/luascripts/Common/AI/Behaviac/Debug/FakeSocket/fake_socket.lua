-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Debug\\FakeSocket\\fake_socket.lua

local functions = require("Common.AI.Behaviac.Functions")
local FakeServer = require("Common.AI.Behaviac.Debug.FakeSocket.fake_server")
local _M = functions.class("FakeSocket")

function _M:ctor()
	return
end

function _M.bind(host, port)
	return FakeServer.new()
end

return _M
