-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\TcpClient.lua

local class = require("Core.Framework.Class")
local phonestcore = require("phonestcore")
local Client = require("Core.Net.Client")
local TcpClient = class.Class("TcpClient", Client)

function TcpClient:ctor(handlerType, handlerId)
	TcpClient.super.ctor(self, handlerType, handlerId, phonestcore.ConTypeTcp)
end

return TcpClient
