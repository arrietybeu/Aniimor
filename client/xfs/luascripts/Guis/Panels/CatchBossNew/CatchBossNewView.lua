-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CatchBossNew\\CatchBossNewView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CatchBossNewView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CatchBossNewView = Class.LightClass("CatchBossNewView", UIView)

function CatchBossNewView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listUList = objectReference:GetRefValue("listUList")
	self.txtLvUBaseText = objectReference:GetRefValue("txtLvUBaseText")
	self.txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	self.listElementUList = objectReference:GetRefValue("listElementUList")
	self.bossTxtNameUSDFText = objectReference:GetRefValue("bossTxtNameUSDFText")
	self.bossGenderUWidget = objectReference:GetRefValue("bossGenderUWidget")
	self.bossTxtLvUSDFText = objectReference:GetRefValue("bossTxtLvUSDFText")
	self.bossLineUWidget = objectReference:GetRefValue("bossLineUWidget")
	self.bossOccupationUWidget = objectReference:GetRefValue("bossOccupationUWidget")
	self.bossIconOccupationUImage = objectReference:GetRefValue("bossIconOccupationUImage")
	self.bossTxtOccupationUSDFText = objectReference:GetRefValue("bossTxtOccupationUSDFText")
	self.bossTxtRewardUSDFText = objectReference:GetRefValue("bossTxtRewardUSDFText")
	self.bossRewardsUList = objectReference:GetRefValue("bossRewardsUList")
	self.ballTxtCatchUSDFText = objectReference:GetRefValue("ballTxtCatchUSDFText")
	self.btnCancelUButton = objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnCancelTxtNameUSDFText = objectReference:GetRefValue("btnCancelTxtNameUSDFText")
	self.btnConfirmTxtNameUSDFText = objectReference:GetRefValue("btnConfirmTxtNameUSDFText")
	self.consumeUWidget = objectReference:GetRefValue("consumeUWidget")
	self.txtConsumeUSDFText = objectReference:GetRefValue("txtConsumeUSDFText")
	self.iconConsumeUImage = objectReference:GetRefValue("iconConsumeUImage")
	self.comsumeTxtNumUSDFText = objectReference:GetRefValue("comsumeTxtNumUSDFText")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.bossInfoUComponent = objectReference:GetRefValue("bossInfoUComponent")
end

function CatchBossNewView:registerObjects()
	return
end

function CatchBossNewView:initView()
	return
end

function CatchBossNewView:onDestroy()
	self:setViewVisibleByOutOfView(false)
end

return CatchBossNewView
