-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonPlayerSkillTip\\CommonPlayerSkillTipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CommonPlayerSkillTipView = Class.LightClass("CommonPlayerSkillTipView", UIView)

function CommonPlayerSkillTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.icon = self.objectReference:GetRefValue("icon")
	self.skillName = self.objectReference:GetRefValue("skillName")
	self.txtLevel = self.objectReference:GetRefValue("txtLevel")
	self.elementList = self.objectReference:GetRefValue("elementList")
	self.videoSkill = self.objectReference:GetRefValue("videoSkill")
	self.btnVideo = self.objectReference:GetRefValue("btnVideo")
	self.btnDownload = self.objectReference:GetRefValue("btnDownload")
	self.txtDetail = self.objectReference:GetRefValue("txtDetail")
	self.upEffectList = self.objectReference:GetRefValue("upEffectList")
	self.consumeList = self.objectReference:GetRefValue("consumeList")
	self.txtBtnName = self.objectReference:GetRefValue("txtBtnName")
	self.btnEquip = self.objectReference:GetRefValue("btnEquip")
	self.btnEquip2 = self.objectReference:GetRefValue("btnEquip2")
	self.textMaxLv = self.objectReference:GetRefValue("textMaxLv")
	self.btnLearn = self.objectReference:GetRefValue("btnLearn")
	self.btnActiveUp = self.objectReference:GetRefValue("btnActiveUp")
	self.btnPassUp = self.objectReference:GetRefValue("btnPassUp")
	self.rootCmp = self.transform:GetComponent("UPopupForm")
	self.btnEquipText = self:findBtnEquipText(self.btnEquip)
	self.btnEquipText2 = self:findBtnEquipText(self.btnEquip2)
end

function CommonPlayerSkillTipView:findBtnEquipText(button)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")

	return txtNameUText
end

function CommonPlayerSkillTipView:registerObjects()
	return
end

function CommonPlayerSkillTipView:initView()
	return
end

return CommonPlayerSkillTipView
