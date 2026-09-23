-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\Server.lua

local class = require("Core.Framework.Class")
local phonestcore = require("phonestcore")
local Server = class.Class("Server")

function Server:ctor(handlerType, handlerId, conType)
	self.handlerType = handlerType
	self.handlerId = handlerId
	self.cObj = phonestcore.newServer(conType)
end

function Server:destroy()
	if self.cObj ~= nil then
		self.cObj:destroyServer()

		self.cObj = nil
	end
end

function Server:start(ip, port, backlog)
	if self.cObj == nil then
		return
	end

	self.cObj:startServer(ip, port, self.handlerType, self.handlerId, backlog)
end

return Server
