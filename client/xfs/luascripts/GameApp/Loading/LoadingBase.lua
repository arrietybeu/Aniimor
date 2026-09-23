-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Loading\\LoadingBase.lua

local Class = require("Core.Framework.Class")
local LoadingBase = Class.LightClass("LoadingBase")

function LoadingBase:ctor(sceneId)
	self.sceneId = sceneId
end

function LoadingBase:startLoading()
	return
end

function LoadingBase:stopLoading()
	return
end

return LoadingBase
