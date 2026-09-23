-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerEnhance\\PlayerEnhanceView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PlayerEnhanceView = Class.LightClass("PlayerEnhanceView", UIView)

function PlayerEnhanceView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.component = self.objectReference:GetRefValue("component")
	self.btnClosePanel = self.objectReference:GetRefValue("btnClosePanel")
	self.keyList = self.objectReference:GetRefValue("keyList")
	self.pbSkillPage = self.objectReference:GetRefValue("pbSkillPage")
	self.equipPanel = self.objectReference:GetRefValue("equipPanel")
	self.combatList = self.objectReference:GetRefValue("combatList")
	self.exploreList = self.objectReference:GetRefValue("exploreList")
	self.textCG = self.objectReference:GetRefValue("textCG")
	self.btnEquipC = self.objectReference:GetRefValue("btnEquipC")
	self.textEG = self.objectReference:GetRefValue("textEG")
	self.btnEquipE = self.objectReference:GetRefValue("btnEquipE")
	self.textPG = self.objectReference:GetRefValue("textPG")
	self.btnEquipP = self.objectReference:GetRefValue("btnEquipP")
	self.closeBtnUSDFText = self.objectReference:GetRefValue("closeBtnUSDFText")
	self.keyLHotKeyContent = self.objectReference:GetRefValue("keyLHotKeyContent")
	self.keyRHotKeyContent = self.objectReference:GetRefValue("keyRHotKeyContent")
	self.listTabUList = self.objectReference:GetRefValue("listTabUList")
	self.badgeRectTransform = self.objectReference:GetRefValue("badgeRectTransform")
	self.topBackUWidget = self.objectReference:GetRefValue("topBackUWidget")
	self.topUSDFText = self.objectReference:GetRefValue("topUSDFText")

	self:initMainPanel()
end

function PlayerEnhanceView:initMainPanel()
	self.mainPanelOc = self.objectReference:GetRefValue("mainPanelOc")
	self.mainPanelAnimation = self.mainPanelOc.transform:GetComponent("Animation")

	local messageCardUWidget = self.mainPanelOc:GetRefValue("messageCardUWidget")

	self.badgeUList = self.mainPanelOc:GetRefValue("badgeUList")

	self:_initPlayerMessageCard(messageCardUWidget)
end

function PlayerEnhanceView:_initPlayerMessageCard(cardTran)
	local objectReference = cardTran.transform:GetComponent("ObjectReference")

	self.nationLevelUButton = objectReference:GetRefValue("nationLevelUButton")
	self.starUImage = objectReference:GetRefValue("starUImage")
	self.starUSDFText = objectReference:GetRefValue("starUSDFText")
	self.nationLevelHotKeyContent = objectReference:GetRefValue("nationLevelHotKeyContent")
	self.playerNameUSDFText = objectReference:GetRefValue("playerNameUSDFText")
	self.playerTitleUSDFText = objectReference:GetRefValue("playerTitleUSDFText")
	self.playerStarUSDFText = objectReference:GetRefValue("playerStarUSDFText")
	self.btnGoUButton = objectReference:GetRefValue("btnGoUButton")
	self.playerLevelUSDFText = objectReference:GetRefValue("playerLevelUSDFText")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.btnGiftUButton = objectReference:GetRefValue("btnGiftUButton")
	self.btnAmendUButton = objectReference:GetRefValue("btnAmendUButton")
	self.imgLikabilityUImage = objectReference:GetRefValue("imgLikabilityUImage")
	self.btnGONameUSDFText = objectReference:GetRefValue("btnGONameUSDFText")
	self.lvExpUProgress = objectReference:GetRefValue("lvExpUProgress")
	self.txtPetLvUSDFText = objectReference:GetRefValue("txtPetLvUSDFText")
	self.playerLvNumUSDFText = objectReference:GetRefValue("playerLvNumUSDFText")
	self.cardRootCmp = cardTran.transform:GetComponent("UComponent")
end

function PlayerEnhanceView:registerObjects()
	return
end

function PlayerEnhanceView:initView()
	return
end

return PlayerEnhanceView
