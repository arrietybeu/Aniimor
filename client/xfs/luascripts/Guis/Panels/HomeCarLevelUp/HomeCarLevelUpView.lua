-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCarLevelUp\\HomeCarLevelUpView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCarLevelUpView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeCarLevelUpView = Class.LightClass("HomeCarLevelUpView", UIView)

function HomeCarLevelUpView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	self.textLevelUSDFText = objectReference:GetRefValue("textLevelUSDFText")
	self.textDetailUSDFText = objectReference:GetRefValue("textDetailUSDFText")
	self.infoULayoutBox = objectReference:GetRefValue("infoULayoutBox")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.listCostUList = objectReference:GetRefValue("listCostUList")
	self.textNoFillUSDFText = objectReference:GetRefValue("textNoFillUSDFText")
	self.costCoinListUList = objectReference:GetRefValue("costCoinListUList")
	self.btnComfirmUButton = objectReference:GetRefValue("btnComfirmUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.txtMaxUSDFText = objectReference:GetRefValue("txtMaxUSDFText")
	self.listUpgradeUList = objectReference:GetRefValue("listUpgradeUList")
	self.uIPanelUWidget = objectReference:GetRefValue("uIPanelUWidget")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.costItemUWidget = objectReference:GetRefValue("costItemUWidget")
	self.btnLvRewardUButton = objectReference:GetRefValue("btnLvRewardUButton")
	self.btnLvRewardText = objectReference:GetRefValue("btnLvRewardText")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.levelRewardsUContainer = objectReference:GetRefValue("levelRewardsUContainer")
	self.btnReadyUWidget = objectReference:GetRefValue("btnReadyUWidget")
	self.scrollRectDescUScrollRect = objectReference:GetRefValue("scrollRectDescUScrollRect")
	self.upgradeTimeUWidget = objectReference:GetRefValue("upgradeTimeUWidget")
	self.txtDetailsUSDFText = objectReference:GetRefValue("txtDetailsUSDFText")
	self.countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	self.txtLevelTimeUSDFText = objectReference:GetRefValue("txtLevelTimeUSDFText")
	self.txtTimeCostUSDFText = objectReference:GetRefValue("txtTimeCostUSDFText")

	local infoULayoutBox = self.infoULayoutBox.transform:GetComponent("ObjectReference")

	self.titleUSDFText = infoULayoutBox:GetRefValue("titleUSDFText")
	self.listUList = infoULayoutBox:GetRefValue("listUList")
	self.titleTextPlus = infoULayoutBox:GetRefValue("titleTextPlus")
	self.contentUpgradeUWidget = infoULayoutBox:GetRefValue("contentUpgradeUWidget")
	self.listUnlockUList = infoULayoutBox:GetRefValue("listUnlockUList")
end

function HomeCarLevelUpView:registerObjects()
	return
end

function HomeCarLevelUpView:initView()
	return
end

return HomeCarLevelUpView
