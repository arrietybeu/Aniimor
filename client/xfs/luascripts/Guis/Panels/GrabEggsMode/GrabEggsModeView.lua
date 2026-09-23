-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsMode\\GrabEggsModeView.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggsModeView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GrabEggsModeView = Class.LightClass("GrabEggsModeView", UIView)

function GrabEggsModeView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.bg = objectReference:GetRefValue("bg")
	self.oldBg = objectReference:GetRefValue("oldBg")
	self.peopleImg = objectReference:GetRefValue("peopleImg")
	self.oldPeopleImg = objectReference:GetRefValue("oldPeopleImg")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.dungeonNameUText = objectReference:GetRefValue("dungeonNameUText")
	self.dungeonScrollRect = objectReference:GetRefValue("dungeonScrollRect")
	self.dangerousTip = objectReference:GetRefValue("dangerousTip")
	self.gradTxt = objectReference:GetRefValue("gradTxt")
	self.rewardUList = objectReference:GetRefValue("rewardUList")
	self.peopleNumUBaseText = objectReference:GetRefValue("peopleNumUBaseText")
	self.rewardUWidget = objectReference:GetRefValue("rewardUWidget")
	self.rewardList = objectReference:GetRefValue("rewardList")
	self.backTitle = objectReference:GetRefValue("backTitle")
	self.selectorUSelector = objectReference:GetRefValue("selectorUSelector")
	self.btnGoToUButton = objectReference:GetRefValue("btnGoToUButton")
	self.waitUWidget = objectReference:GetRefValue("waitUWidget")
	self.textWarningTip = objectReference:GetRefValue("textWarningTip")
	self.btnTeam1UButton = objectReference:GetRefValue("btnTeam1UButton")
	self.btnTeam2UButton = objectReference:GetRefValue("btnTeam2UButton")
	self.btnTeam3UButton = objectReference:GetRefValue("btnTeam3UButton")

	local btnTeam1ObjectReference = self.btnTeam1UButton.transform:GetComponent("ObjectReference")

	self.chaosName = btnTeam1ObjectReference:GetRefValue("chaosName")
	self.chaosName2 = btnTeam1ObjectReference:GetRefValue("chaosName2")
	self.textTeamNum = objectReference:GetRefValue("textTeamNum")
	self.currencyItem = objectReference:GetRefValue("currencyItem")
	self.textTimeLimit = objectReference:GetRefValue("textTimeLimit")
	self.textLvLimit = objectReference:GetRefValue("textLvLimit")
	self.textPetLvLimit = objectReference:GetRefValue("textPetLvLimit")
	self.textWarningTip = objectReference:GetRefValue("textWarningTip")
	self.btnStoreUButton = objectReference:GetRefValue("btnStoreUButton")
	self.btnEquipUButton = objectReference:GetRefValue("btnEquipUButton")
	self.btnTalentUButton = objectReference:GetRefValue("btnTalentUButton")
	self.textTimeTips = objectReference:GetRefValue("textTimeTips")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.keyR3HotKeyContent = objectReference:GetRefValue("keyR3HotKeyContent")
	self.consoleBar = objectReference:GetRefValue("consoleBar")
	self.skillList = objectReference:GetRefValue("skillList")
	self.seasonInfoUContainer = objectReference:GetRefValue("seasonInfoUContainer")
	self.protectUSDFText = objectReference:GetRefValue("protectUSDFText")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.iconUp3USDFText = objectReference:GetRefValue("iconUp3USDFText")
	self.iconUp3UButton = objectReference:GetRefValue("iconUp3UButton")
	self.upTipUContainer = objectReference:GetRefValue("upTipUContainer")
	self.dropHintUContainer = objectReference:GetRefValue("dropHintUContainer")
	self.propagandaPoster = objectReference:GetRefValue("posterUContainer")

	self.propagandaPoster:SetActive(false)

	self.rootUWidget = self.transform:GetComponent("UComponent")
	self.txtLimitNameUSDFText = objectReference:GetRefValue("txtLimitNameUSDFText")
	self.btnForgingUButton = objectReference:GetRefValue("btnForgingUButton")
	self.btnCollectionUButton = objectReference:GetRefValue("btnCollectionUButton")
	self.btnTalenttxtNameUBaseText = self.btnTalentUButton.transform:GetComponent("ObjectReference"):GetRefValue("txtNameUBaseText")
	self.btnEquiptxtNameUBaseText = self.btnEquipUButton.transform:GetComponent("ObjectReference"):GetRefValue("txtNameUBaseText")
	self.btnStoretxtNameUBaseText = self.btnStoreUButton.transform:GetComponent("ObjectReference"):GetRefValue("txtNameUBaseText")
	self.btnForgingtxtNameUBaseText = self.btnForgingUButton.transform:GetComponent("ObjectReference"):GetRefValue("txtNameUBaseText")
	self.btnCollectionNameUBaseText = self.btnCollectionUButton.transform:GetComponent("ObjectReference"):GetRefValue("txtNameUBaseText")

	local btnGoToObjectReference = self.btnGoToUButton.transform:GetComponent("ObjectReference")

	self.chaosCost = btnGoToObjectReference:GetRefValue("chaosCost")
	self.chaosCostIcon = btnGoToObjectReference:GetRefValue("chaosCostIcon")
	self.chaosCostCurTicket = btnGoToObjectReference:GetRefValue("chaosCostCurTicket")
end

function GrabEggsModeView:registerObjects()
	return
end

function GrabEggsModeView:initView()
	return
end

return GrabEggsModeView
