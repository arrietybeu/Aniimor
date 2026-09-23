-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ChainAttack\\ChainAttackView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ChainAttackView = Class.LightClass("ChainAttackView", UIView)

function ChainAttackView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.petList = self.objectReference:GetRefValue("petList")
	self.chainPetList = self.objectReference:GetRefValue("chainPetList")
	self.leftSlider = self.objectReference:GetRefValue("leftSlider")
	self.rightSlider = self.objectReference:GetRefValue("rightSlider")
	self.bonusText = self.objectReference:GetRefValue("bonusText")
	self.totalDamageDancer = self.objectReference:GetRefValue("totalDamageDancer")
	self.chainTotalDamage = self.objectReference:GetRefValue("chainTotalDamage")
	self.damagePanel = self.objectReference:GetRefValue("damagePanel")
	self.qteLineUComponent = self.objectReference:GetRefValue("qteLineUComponent")
end

function ChainAttackView:registerObjects()
	return
end

function ChainAttackView:initView()
	return
end

return ChainAttackView
