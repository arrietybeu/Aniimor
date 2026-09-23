-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchDetailV2\\Component\\PetResearchProgressComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RedDotConst = require("Const.RedDotConst")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetResearchProgressComponent = Class.LightClass("PetResearchProgressComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")

function PetResearchProgressComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.numUSDFText = objectReference:GetRefValue("numUSDFText")
	self.layoutBoxRectTransform = objectReference:GetRefValue("layoutBoxRectTransform")
	self.imgBg1UWidget = objectReference:GetRefValue("imgBg1UWidget")
	self.imgBg2UWidget = objectReference:GetRefValue("imgBg2UWidget")
	self.imgBg3UWidget = objectReference:GetRefValue("imgBg3UWidget")
	self.imgBg4UWidget = objectReference:GetRefValue("imgBg4UWidget")
	self.line1UWidget = objectReference:GetRefValue("line1UWidget")
	self.line2UWidget = objectReference:GetRefValue("line2UWidget")
	self.line3UWidget = objectReference:GetRefValue("line3UWidget")
	self.progressFillUProgress = objectReference:GetRefValue("progressFillUProgress")
	self.iconRewardUImage = objectReference:GetRefValue("iconRewardUImage")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.progressBg = {
		self.imgBg1UWidget,
		self.imgBg2UWidget,
		self.imgBg3UWidget,
		self.imgBg4UWidget
	}
	self.lines = {
		self.line1UWidget,
		self.line2UWidget,
		self.line3UWidget
	}
end

function PetResearchProgressComponent:initView()
	local rect = self.layoutBoxRectTransform.rect

	self.progressWidth = rect.width
	self.progressHeight = rect.height

	ClientTextUtils.setText(self.txtTitleUSDFText, pg.getGameString("RESEARCH_POINT"))
end

function PetResearchProgressComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function PetResearchProgressComponent:setPetResearchPoint()
	local researchPointInfo = PetResearchUtils.getPetResearchFullProgress(self.model.curPetTemplateId)

	if researchPointInfo.isResearched then
		self.uWidget:TryChangePage("FullReaserch", 1)
	else
		self.uWidget:TryChangePage("FullReaserch", 0)

		for idx = 1, Const.PET_RESEARCH_REWARD_LEVEL_SHOW_MAX do
			local size = Vector2(self.progressWidth * researchPointInfo["levelRatio" .. idx], self.progressHeight)

			self.progressBg[idx].sizeDelta = size

			if self.lines[idx] then
				self.lines[idx].sizeDelta = size
			end
		end

		self.progressFillUProgress.minValue = 0
		self.progressFillUProgress.maxValue = researchPointInfo.needExp
		self.progressFillUProgress.value = researchPointInfo.exp

		local level = researchPointInfo.level == Const.PET_RESEARCH_REWARD_LEVEL_SHOW_MAX and researchPointInfo.level or researchPointInfo.level + 1

		ClientTextUtils.setText(self.numUSDFText, string.format("%s/%s", researchPointInfo["levelGot" .. level], researchPointInfo["levelNeed" .. level]))

		self.iconRewardUImage.url = researchPointInfo.icon

		self.uWidget:TryChangePage("Crown", PetResearchUtils.LEVEL_QUALITY_NAME[researchPointInfo.level])
	end
end

return PetResearchProgressComponent
