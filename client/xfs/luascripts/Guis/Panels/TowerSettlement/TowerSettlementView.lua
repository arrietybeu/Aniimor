-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerSettlement\\TowerSettlementView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerSettlementView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TowerSettlementView = Class.LightClass("TowerSettlementView", UIView)

function TowerSettlementView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.timeUBaseText1 = objectReference:GetRefValue("timeUBaseText1")
	self.mvpPetUImage = objectReference:GetRefValue("mvpPetUImage")
	self.mvpPetNameUBaseText = objectReference:GetRefValue("mvpPetNameUBaseText")
	self.mvpAttackUBaseText = objectReference:GetRefValue("mvpAttackUBaseText")
	self.mvpDefUBaseText = objectReference:GetRefValue("mvpDefUBaseText")
	self.mvpHealUBaseText = objectReference:GetRefValue("mvpHealUBaseText")
	self.mvpLvUBaseText = objectReference:GetRefValue("mvpLvUBaseText")
	self.petUImage2 = objectReference:GetRefValue("petUImage2")
	self.petNameUBaseText2 = objectReference:GetRefValue("petNameUBaseText2")
	self.petLvUBaseText2 = objectReference:GetRefValue("petLvUBaseText2")
	self.petUImage3 = objectReference:GetRefValue("petUImage3")
	self.petNameUBaseText3 = objectReference:GetRefValue("petNameUBaseText3")
	self.petLvUBaseText3 = objectReference:GetRefValue("petLvUBaseText3")
	self.petUImage4 = objectReference:GetRefValue("petUImage4")
	self.petNameUBaseText4 = objectReference:GetRefValue("petNameUBaseText4")
	self.petLvUBaseText4 = objectReference:GetRefValue("petLvUBaseText4")
	self.petUImage5 = objectReference:GetRefValue("petUImage5")
	self.petNameUBaseText5 = objectReference:GetRefValue("petNameUBaseText5")
	self.petLvUBaseText5 = objectReference:GetRefValue("petLvUBaseText5")
	self.coinNumberUBaseText = objectReference:GetRefValue("coinNumberUBaseText")
	self.bossBuffUButton = objectReference:GetRefValue("bossBuffUButton")
	self.listBuffUList = objectReference:GetRefValue("listBuffUList")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.scoreUComponent1 = objectReference:GetRefValue("scoreUComponent1")
	self.scoreUComponent2 = objectReference:GetRefValue("scoreUComponent2")
	self.scoreUComponent3 = objectReference:GetRefValue("scoreUComponent3")
	self.scoreUComponent4 = objectReference:GetRefValue("scoreUComponent4")
	self.scoreUComponent5 = objectReference:GetRefValue("scoreUComponent5")
	self.timeUBaseText2 = objectReference:GetRefValue("timeUBaseText2")
	self.equipmentUImage1 = objectReference:GetRefValue("equipmentUImage1")
	self.equipmentUImage2 = objectReference:GetRefValue("equipmentUImage2")
	self.equipmentUImage3 = objectReference:GetRefValue("equipmentUImage3")
	self.equipmentUImage4 = objectReference:GetRefValue("equipmentUImage4")
	self.equipmentUImage5 = objectReference:GetRefValue("equipmentUImage5")
	self.equipmentUList = objectReference:GetRefValue("equipmentUList")
	self.backgroundUImage = objectReference:GetRefValue("backgroundUImage")
	self.killCountUBaseText = objectReference:GetRefValue("killCountUBaseText")
	self.maxUWidget = objectReference:GetRefValue("maxUWidget")
	self.levelNameSuccUBaseText = objectReference:GetRefValue("levelNameSuccUBaseText")
	self.levelNameFailedUBaseText = objectReference:GetRefValue("levelNameFailedUBaseText")
	self.doubleRewardUWidget = objectReference:GetRefValue("doubleRewardUWidget")
end

function TowerSettlementView:registerObjects()
	return
end

function TowerSettlementView:initView()
	return
end

return TowerSettlementView
