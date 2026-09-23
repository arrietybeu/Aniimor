-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomePlantsManual\\HomePlantsManualView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomePlantsManualView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomePlantsManualView = Class.LightClass("HomePlantsManualView", UIView)

function HomePlantsManualView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.plantUList = objectReference:GetRefValue("plantUList")
	self.rewardList = objectReference:GetRefValue("rewardList")
	self.curNumUSDFText = objectReference:GetRefValue("curNumUSDFText")
	self.allNumUSDFText = objectReference:GetRefValue("allNumUSDFText")
	self.btnArrow1UButton = objectReference:GetRefValue("btnArrow1UButton")
	self.btnArrow2UButton = objectReference:GetRefValue("btnArrow2UButton")
	self.listPointUList = objectReference:GetRefValue("listPointUList")
	self.lastRewardUButton = objectReference:GetRefValue("lastRewardUButton")
end

function HomePlantsManualView:registerObjects()
	return
end

function HomePlantsManualView:initView()
	return
end

return HomePlantsManualView
