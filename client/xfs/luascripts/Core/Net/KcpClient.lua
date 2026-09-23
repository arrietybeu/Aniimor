-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\KcpClient.lua

local class = require("Core.Framework.Class")
local phonestcore = require("phonestcore")
local Client = require("Core.Net.Client")
local KcpClient = class.Class("KcpClient", Client)

function KcpClient:ctor(handlerType, handlerId)
	KcpClient.super.ctor(self, handlerType, handlerId, phonestcore.ConTypeKcp)
end

return KcpClient
