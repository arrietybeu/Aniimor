-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\TcpServer.lua

local class = require("Core.Framework.Class")
local phonestcore = require("phonestcore")
local Server = require("Core.Net.Server")
local TcpServer = class.Class("TcpServer", Server)

function TcpServer:ctor(handlerType, handlerId)
	TcpServer.super.ctor(self, handlerType, handlerId, phonestcore.ConTypeTcp)
end

return TcpServer
