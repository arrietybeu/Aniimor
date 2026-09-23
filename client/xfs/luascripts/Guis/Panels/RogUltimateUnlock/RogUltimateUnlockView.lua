-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogUltimateUnlock\\RogUltimateUnlockView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local RogueUtils = require("Utils.RogueUtils")
local RogUltimateUnlockView = Class.LightClass("RogUltimateUnlockView", UIView)

function RogUltimateUnlockView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootComponent = self.objectReference:GetRefValue("rootComponent")
	self.imgUltimateUnlock = self.objectReference:GetRefValue("imgUltimateUnlock")
	self.txtUltimateUnlock = self.objectReference:GetRefValue("txtUltimateUnlock")
	self.itemUltimate = self.objectReference:GetRefValue("itemUltimate")
	self.itemSkill1 = self.objectReference:GetRefValue("itemSkill1")
	self.itemSkill2 = self.objectReference:GetRefValue("itemSkill2")
	self.itemPet = {}
	self.itemPet[1] = self.objectReference:GetRefValue("itemPet1")
	self.itemPet[2] = self.objectReference:GetRefValue("itemPet2")
	self.itemPet[3] = self.objectReference:GetRefValue("itemPet3")
	self.itemPet[4] = self.objectReference:GetRefValue("itemPet4")
	self.itemPet[5] = self.objectReference:GetRefValue("itemPet5")
	self.btnRules = self.objectReference:GetRefValue("btnRules")
	self.btnClose = self.objectReference:GetRefValue("btnClose")

	local itemRadar = self.objectReference:GetRefValue("itemRadar")

	self.compRadar = RogueUtils.getUltimatePetPropRadarBind(itemRadar)
	self.animRoot = self.objectReference:GetRefValue("animRoot")
	self.imgBossUImage = self.objectReference:GetRefValue("imgBossUImage")
	self.bossTipUBaseText = self.objectReference:GetRefValue("bossTipUBaseText")
end

return RogUltimateUnlockView
