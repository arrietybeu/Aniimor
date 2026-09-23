-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarLoading\\AvatarLoadingView.lua

local logger = require("Core.Log.LoggerManager").getLogger("AvatarLoadingView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local AvatarLoadingView = Class.LightClass("AvatarLoadingView", UIView)

function AvatarLoadingView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.progressUProgress = self.objectReference:GetRefValue("progressUProgress")
	self.numUSDFText = self.objectReference:GetRefValue("numUSDFText")
end

function AvatarLoadingView:registerObjects()
	return
end

function AvatarLoadingView:initView()
	return
end

return AvatarLoadingView
