-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomePlantsManualDetail\\HomePlantsManualDetailView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomePlantsManualDetailView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomePlantsManualDetailView = Class.LightClass("HomePlantsManualDetailView", UIView)

function HomePlantsManualDetailView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.listUList = objectReference:GetRefValue("listUList")
	self.iconUImage = objectReference:GetRefValue("iconUImage")
	self.txtUSDFText = objectReference:GetRefValue("txtUSDFText")
	self.btnClaimUButton = objectReference:GetRefValue("btnClaimUButton")
	self.btnReadyUWidget = objectReference:GetRefValue("btnReadyUWidget")
	self.rewardList = objectReference:GetRefValue("rewardList")
	self.btnPokedexUWidget = objectReference:GetRefValue("btnPokedexUWidget")
	self.autoHarvestUWidget = objectReference:GetRefValue("autoHarvestUWidget")
	self.btnAutoCollectSwitchUButton = objectReference:GetRefValue("btnAutoCollectSwitchUButton")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTips")
	self.txtSwitchNameUSDFText = objectReference:GetRefValue("txtSwitchName")
end

function HomePlantsManualDetailView:registerObjects()
	return
end

function HomePlantsManualDetailView:initView()
	return
end

return HomePlantsManualDetailView
