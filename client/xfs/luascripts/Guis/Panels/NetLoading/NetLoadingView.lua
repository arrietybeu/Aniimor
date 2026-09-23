-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\NetLoading\\NetLoadingView.lua

local logger = require("Core.Log.LoggerManager").getLogger("NetLoadingView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local NetLoadingView = Class.LightClass("NetLoadingView", UIView)

function NetLoadingView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.textLoadingUBaseText = objectReference:GetRefValue("textLoadingUBaseText")
end

function NetLoadingView:registerObjects()
	return
end

function NetLoadingView:initView()
	return
end

return NetLoadingView
