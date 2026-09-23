-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetUpSkill\\PetUpSkillView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetUpSkillView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetUpSkillView = Class.LightClass("PetUpSkillView", UIView)

function PetUpSkillView:findObjects()
	return
end

function PetUpSkillView:registerObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.petSkillUButton = objectReference:GetRefValue("petSkillUButton")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.infoTxtTipsUSDFText = objectReference:GetRefValue("infoTxtTipsUSDFText")
	self.skillBeforeUComponent = objectReference:GetRefValue("skillBeforeUComponent")
	self.skillAfterUComponent = objectReference:GetRefValue("skillAfterUComponent")
	self.btnConsumeUButton = objectReference:GetRefValue("btnConsumeUButton")
	self.lockUImage = objectReference:GetRefValue("lockUImage")
	self.iconConsumeUImage = objectReference:GetRefValue("iconConsumeUImage")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.btnNoneCostUButton = objectReference:GetRefValue("btnNoneCostUButton")
	self.btnConsumeTxt = objectReference:GetRefValue("btnConsumeTxt")
end

function PetUpSkillView:initView()
	return
end

return PetUpSkillView
