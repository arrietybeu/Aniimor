-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Debug\\FakeSocket\\fake_client.lua

local functions = require("Common.AI.Behaviac.Functions")
local _M = functions.class("FakeClient")

function _M:ctor()
	self.receive_msg = "[continue]\n[profiling] false\n[start]\n"
	self.file = io.open("logs/behaviac.log", "w+")
end

function _M:close()
	if self.file then
		self.file:close()
	end
end

function _M:send(text)
	self.file:write(text)
end

function _M:settimeout(timeout)
	return
end

function _M:receive(length)
	local msg = self.receive_msg

	self.receive_msg = ""

	return nil, "timeout", msg
end

return _M
