-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\KcpServer.lua

local class = require("Core.Framework.Class")
local phonestcore = require("phonestcore")
local Server = require("Core.Net.Server")
local KcpServer = class.Class("KcpServer", Server)

function KcpServer:ctor(handlerType, handlerId)
	KcpServer.super.ctor(self, handlerType, handlerId, phonestcore.ConTypeKcp)
end

return KcpServer
