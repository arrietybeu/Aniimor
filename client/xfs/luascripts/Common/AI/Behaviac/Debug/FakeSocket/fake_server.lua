-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Debug\\FakeSocket\\fake_server.lua

local functions = require("Common.AI.Behaviac.Functions")
local FakeClient = require("Common.AI.Behaviac.Debug.FakeSocket.fake_client")
local _M = functions.class("FakeServer")

function _M:ctor()
	return
end

function _M:accept()
	if pg.btDebugPlayerId == nil then
		return nil
	end

	return FakeClient.new(), ""
end

function _M:settimeout(timeout)
	return
end

return _M
