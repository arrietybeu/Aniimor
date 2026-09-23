-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerSelectPet\\TowerSelectPetView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerSelectPetView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TowerSelectPetView = Class.LightClass("TowerSelectPetView", UIView)

function TowerSelectPetView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.midPanelTransform = self.objectReference:GetRefValue("midPanelTransform")
	self.rightPanelTransform = self.objectReference:GetRefValue("rightPanelTransform")
	self.textLvUBaseText = self.objectReference:GetRefValue("textLvUBaseText")
	self.listRoundUList = self.objectReference:GetRefValue("listRoundUList")
	self.listBattleUList = self.objectReference:GetRefValue("listBattleUList")
	self.btnBorrowAnimoUButton = self.objectReference:GetRefValue("btnBorrowAnimoUButton")
	self.borrowAnimoCountUBaseText = self.objectReference:GetRefValue("borrowAnimoCountUBaseText")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.btnLevelupUButton = self.objectReference:GetRefValue("btnLevelupUButton")
	self.btnCultivateUButton = self.objectReference:GetRefValue("btnCultivateUButton")
	self.btnSkillsUButton = self.objectReference:GetRefValue("btnSkillsUButton")
	self.btnDressUButton = self.objectReference:GetRefValue("btnDressUButton")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.catchRogueTipsTxt = self.objectReference:GetRefValue("catchRogueTipsTxt")
	self.roomTitleTowerUWidget = self.objectReference:GetRefValue("roomTitleTowerUWidget")
	self.roomTitleBossUContainer = self.objectReference:GetRefValue("roomTitleBossUContainer")
end

function TowerSelectPetView:registerObjects()
	return
end

function TowerSelectPetView:initView()
	return
end

return TowerSelectPetView
