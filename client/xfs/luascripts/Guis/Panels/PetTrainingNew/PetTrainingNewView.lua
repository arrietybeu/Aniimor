-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTrainingNew\\PetTrainingNewView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetTrainingNewView = Class.LightClass("PetTrainingNewView", UIView)

function PetTrainingNewView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.root = self.objectReference:GetRefValue("root")
	self.tabList = self.objectReference:GetRefValue("tabList")
	self.newTalentUComponent = self.objectReference:GetRefValue("newTalentUComponent")
	self.starUpUComponent = self.objectReference:GetRefValue("starUpUComponent")
	self.evolutionUComponent = self.objectReference:GetRefValue("evolutionUComponent")
	self.carryUComponent = self.objectReference:GetRefValue("carryUComponent")
	self.tMPUSDFText = self.objectReference:GetRefValue("tMPUSDFText")
	self.tabLeft = self.objectReference:GetRefValue("tabLeft")
	self.upHotKeyContent = self.objectReference:GetRefValue("upHotKeyContent")
	self.downHotKeyContent = self.objectReference:GetRefValue("downHotKeyContent")
	self.tabLeftHotKeyContent = self.objectReference:GetRefValue("tabLeftHotKeyContent")
	self.tabRightHotKeyContent = self.objectReference:GetRefValue("tabRightHotKeyContent")
	self.newSkillPanelUComponent = self.objectReference:GetRefValue("newSkillPanelUComponent")
	self.imgPetUImage = self.objectReference:GetRefValue("imgPetUImage")
	self.jewelTabUWidget = self.objectReference:GetRefValue("jewelTabUWidget")
	self.centerTabUWidget = self.objectReference:GetRefValue("centerTabUWidget")

	self:findTabLeft()
end

function PetTrainingNewView:findTabLeft()
	self.tabLeftOc = self.tabLeft.transform:GetComponent("ObjectReference")
	self.petManage = self.tabLeftOc:GetRefValue("petManage")
	self.tabPetList = self.tabLeftOc:GetRefValue("tabPetList")
	self.btnPetBox = self.tabLeftOc:GetRefValue("btnPetBox")
end

function PetTrainingNewView:initView()
	return
end

return PetTrainingNewView
