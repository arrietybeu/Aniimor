-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\Scheduler.lua

local class = require("Core.Framework.Class")
local phonestcore = require("phonestcore")
local SafeCallback = require("Core.Framework.SafeCallback")
local Scheduler = class.Class("Scheduler")

function Scheduler:start(ioNum)
	phonestcore.startIO(ioNum)
end

function Scheduler:poll()
	phonestcore.pullIO()
end

function Scheduler:clientSendMessage()
	if phonestcore.clientSendMessage ~= nil then
		phonestcore.clientSendMessage()
	end
end

function Scheduler:setPollInterval(interval)
	phonestcore.setPullIOInterval(interval)

	self.interval = interval
end

function Scheduler:stop()
	phonestcore.stopIO()
end

function Scheduler:tick()
	if self.tickCb ~= nil then
		self.tickCb()
	end
end

function Scheduler:setTickCb(func)
	if type(func) ~= "function" then
		error("Scheduler:setTickCb func not function type")
	end

	self.tickCb = func
end

return Scheduler
