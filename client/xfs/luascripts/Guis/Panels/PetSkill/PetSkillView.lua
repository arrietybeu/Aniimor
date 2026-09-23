-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSkill\\PetSkillView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetSkillView = Class.LightClass("PetSkillView", UIView)

function PetSkillView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.imgPetUImage = self.objectReference:GetRefValue("imgPetUImage")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.listCurrencyUList = self.objectReference:GetRefValue("listCurrencyUList")
	self.skillSwapUButton = self.objectReference:GetRefValue("skillSwapUButton")
	self.petName = self.objectReference:GetRefValue("petName")
	self.skillLearnUButton = self.objectReference:GetRefValue("skillLearnUButton")
	self.root = self.objectReference:GetRefValue("root")
	self.btnSkillPresetsUButton = self.objectReference:GetRefValue("btnSkillPresetsUButton")
	self.skillPresetUContainer = self.objectReference:GetRefValue("skillPresetUContainer")
	self.skillPresetName = self.objectReference:GetRefValue("skillPresetName")
	self.allSkillsList = self.objectReference:GetRefValue("allSkillsList")
	self.btnSwapUButton = self.objectReference:GetRefValue("btnSwapUButton")
	self.skillInfoUComponent = self.objectReference:GetRefValue("skillInfoUComponent")
	self.skillLearnList = self.objectReference:GetRefValue("skillLearnList")
	self.learnSkillInfoUComponent = self.objectReference:GetRefValue("learnSkillInfoUComponent")
	self.learnConsumeUList = self.objectReference:GetRefValue("learnConsumeUList")
	self.btnStudyUButton = self.objectReference:GetRefValue("btnStudyUButton")
	self.skillLearnTip = self.objectReference:GetRefValue("skillLearnTip")
	self.descUSDFText = self.objectReference:GetRefValue("descUSDFText")
end

function PetSkillView:initView()
	return
end

return PetSkillView
