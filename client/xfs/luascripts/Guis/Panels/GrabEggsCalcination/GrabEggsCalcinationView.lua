-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsCalcination\\GrabEggsCalcinationView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GrabEggsCalcinationView = Class.LightClass("GrabEggsCalcinationView", UIView)

function GrabEggsCalcinationView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootWidget = self.transform:GetComponent("UWidget")

	local titleUWidget = objectReference:GetRefValue("titleUWidget")

	self.performanceTitleGameObject = titleUWidget and titleUWidget.gameObject or nil
	self.performanceLeftRectTransform = objectReference:GetRefValue("panelLeftRectTransform")
	self.performanceRightRectTransform = objectReference:GetRefValue("panelRightRectTransform")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.btnBackUSDFText = objectReference:GetRefValue("btnBackUSDFText")
	self.CalcinationtextUSDFText = objectReference:GetRefValue("CalcinationtextUSDFText")
	self.forgItemlistUList = objectReference:GetRefValue("forgItemlistUList")
	self.emptyTextUSDFText = objectReference:GetRefValue("emptyTextUSDFText")
	self.chooseItemtextUSDFText = objectReference:GetRefValue("chooseItemtextUSDFText")
	self.tag1UWidget = objectReference:GetRefValue("tag1UWidget")
	self.tag2UWidget = objectReference:GetRefValue("tag2UWidget")
	self.tag3UWidget = objectReference:GetRefValue("tag3UWidget")
	self.levelInfoUWidget = objectReference:GetRefValue("levelInfoUWidget")

	if self.levelInfoUWidget then
		local levelTag = self.levelInfoUWidget.transform:Find("LevelTag")

		if levelTag then
			self.levelIconUImage = levelTag:Find("LevelIcon"):GetComponent("UImage")
			self.levelBgUImage = levelTag:Find("LevelBg"):GetComponent("UImage")
			self.levelIconUImage.forceSyncLoad = true
			self.levelBgUImage.forceSyncLoad = true
		end
	end

	self.textLVTitleUSDFText = objectReference:GetRefValue("textLVTitleUSDFText")
	self.textLVNameUSDFText = objectReference:GetRefValue("textLVNameUSDFText")
	self.sliderUSlider = objectReference:GetRefValue("sliderUSlider")
	self.textValueRateNumUSDFText = objectReference:GetRefValue("textValueRateNumUSDFText")
	self.textValueNumUSDFText = objectReference:GetRefValue("textValueNumUSDFText")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.txtbtnComfirmNameUSDFText = objectReference:GetRefValue("txtbtnComfirmNameUSDFText")
	self.textValueUSDFText = objectReference:GetRefValue("textValueUSDFText")
	self.calcinationUButton = objectReference:GetRefValue("calcinationUButton")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.textCostNumUSDFText = objectReference:GetRefValue("textCostNumUSDFText")
	self.flyNodeUWidget = objectReference:GetRefValue("flyNodeUWidget")
	self.tagWidgets = {
		self.tag1UWidget,
		self.tag2UWidget,
		self.tag3UWidget
	}
end

function GrabEggsCalcinationView:registerObjects()
	return
end

function GrabEggsCalcinationView:initView()
	return
end

return GrabEggsCalcinationView
