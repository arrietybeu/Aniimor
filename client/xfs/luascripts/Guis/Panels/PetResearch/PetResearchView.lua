-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearch\\PetResearchView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetResearchView = Class.LightClass("PetResearchView", UIView)

function PetResearchView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.tabCardUWidget = self.objectReference:GetRefValue("tabCardUWidget")
	self.tabMedalUWidget = self.objectReference:GetRefValue("tabMedalUWidget")
	self.bottomKeyListUList = self.objectReference:GetRefValue("bottomKeyListUList")
	self.btnOverviewUButton = self.objectReference:GetRefValue("btnOverviewUButton")
	self.btnOverviewNameUSDFText = self.objectReference:GetRefValue("btnOverviewNameUSDFText")
	self.rootView = self.transform:GetComponent("UComponent")
end

function PetResearchView:registerObjects()
	return
end

function PetResearchView:initView()
	return
end

return PetResearchView
