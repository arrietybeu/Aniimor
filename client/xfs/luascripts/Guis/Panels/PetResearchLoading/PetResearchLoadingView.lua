-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchLoading\\PetResearchLoadingView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetResearchLoadingView = Class.LightClass("PetResearchLoadingView", UIView)

function PetResearchLoadingView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.loadingProgressNumUSDFText = self.objectReference:GetRefValue("loadingProgressNumUSDFText")
end

function PetResearchLoadingView:registerObjects()
	return
end

function PetResearchLoadingView:initView()
	return
end

return PetResearchLoadingView
