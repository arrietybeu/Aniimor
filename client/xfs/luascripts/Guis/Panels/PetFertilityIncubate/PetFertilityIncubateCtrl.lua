-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityIncubate\\PetFertilityIncubateCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = require("Core.Log.LoggerManager").getLogger("PetFertilityIncubateCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SysConfigData = require("Data.sys_config_data")
local Time = require("Core.Common.Time")
local ClientConst = require("Const.ClientConst")
local PetBallConfigData = require("Data.pet_ball_config_data")
local PetFertilityIncubateCtrl = Class.LightClass("PetFertilityIncubateCtrl", UICtrl)
local SoulEggEvolutionConst = require("Common.Const.EvolutionConst").SoulEggEvolution
local IncubateInfo = {
	[0] = {
		title = "HATCHING_EGGS_TOUCH_1",
		rumble = ""
	},
	{
		title = "HATCHING_EGGS_STAGE_1",
		rumble = "CommonLight"
	},
	{
		title = "HATCHING_EGGS_STAGE_2",
		rumble = "CommonMiddle"
	},
	{
		title = "HATCHING_EGGS_STAGE_3",
		rumble = "CommonMiddle"
	},
	{
		title = "HATCHING_EGGS_STAGE_4",
		rumble = "CommonHigh"
	}
}

PetFertilityIncubateCtrl.messages = {}

function PetFertilityIncubateCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self._petInfo = self.model:setUpPetInfo(info.petInfo)
	self._closeCallBack = info.closeCallBack
	self._skipCloseCallBack = info.skipCloseCallBack

	self:init()
end

function PetFertilityIncubateCtrl:addListener()
	function self.view.btnNextUButton.luaClick()
		self:onBtnClickNext()
	end

	function self.view.btnSkipUButton.luaClick()
		self:dismiss()

		if self._skipCloseCallBack then
			self._skipCloseCallBack()
		end
	end
end

function PetFertilityIncubateCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetFertilityIncubateCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info.isGrabEgg then
		self.view.btnSkipUButton:SetActive(false)
	end
end

function PetFertilityIncubateCtrl:onShow()
	return
end

function PetFertilityIncubateCtrl:onHide()
	if self.tipsTimer then
		self:killTimer(self.tipsTimer)

		self.tipsTimer = nil
	end
end

function PetFertilityIncubateCtrl:getTitleByIndex(index)
	local str
	local gameString = pg.getGameString(IncubateInfo[self._curIndex].title)

	if index == 0 then
		str = gameString
	elseif index == 1 then
		str = string.format(gameString, self._petInfo.petFunctionText)
	elseif index == 2 then
		local stage = self._petInfo.stage
		local stageStr = pg.getGameString("PET_STAGE_TXT_" .. stage)

		str = string.format(gameString, stageStr)
	elseif index == 3 then
		local elementStr = LuaUIUtils.getElementNameLocalization(self._petInfo.mainElementType, true)

		str = string.format(gameString, elementStr)
	elseif index == 4 then
		local colorFmt = PetBallConfigData.hatchingQualityColour[self._petInfo.ratingPageIdx + 1]
		local qualityStr = string.format("<color=%s>%s</color>", colorFmt, pg.getGameString(self._petInfo.ratingStr))

		str = string.format(gameString, qualityStr)
	end

	return str
end

function PetFertilityIncubateCtrl:init()
	self:initBubble()

	self._curIndex = 0

	self.view.rootComponent:TryChangePage("TouchState", self._curIndex)

	self._hasTouch = false

	ClientTextUtils.setText(self.view.txtTitieUBaseText, self:getTitleByIndex(self._curIndex))

	local hintStr = pg.getGameString("HATCHING_EGGS_TOUCH_3")

	ClientTextUtils.setText(self.view.hintTxt, hintStr)
	LuaUIUtils.setUIVisible(self.view.hintTxt, false)
	self:startTipsTimer()
	self:refreshEggBtnState()
end

function PetFertilityIncubateCtrl:initBubble()
	for i = 1, #self.view.bubbleList do
		self:renderBubble(self.view.bubbleList[i], i)
	end
end

function PetFertilityIncubateCtrl:renderBubble(bubble, index)
	local objectRef = bubble:GetComponent("ObjectReference")
	local root = objectRef:GetRefValue("root")
	local icon = objectRef:GetRefValue("icon")
	local element = objectRef:GetRefValue("element")
	local text = objectRef:GetRefValue("text")
	local bubbleType = self.model:getBubbleTypeByIndex(index)

	root:TryChangePage("BubbleType", bubbleType ~= self.model.BubbleType.Element and 1 or 0)

	local str, iconUrl

	if bubbleType == self.model.BubbleType.Element then
		element:TryChangePage("type", LuaUIUtils.getElementName(self._petInfo.mainElementType))

		str = LuaUIUtils.getElementNameLocalization(self._petInfo.mainElementType)

		if not self._petInfo.mainElementType and LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("PetFertilityIncubateCtrl: renderBubbleError3 self._petInfo.tempId=%s", self._petInfo.templateId)
		end
	elseif bubbleType == self.model.BubbleType.Char then
		iconUrl = self._petInfo.petFunctionIcon
		str = self._petInfo.petFunctionText
	elseif bubbleType == self.model.BubbleType.Grow then
		local stage = self._petInfo.stage

		iconUrl = self._petInfo.stageIcon
		str = pg.getGameString("PET_STAGE_TXT_" .. stage)
	elseif bubbleType == self.model.BubbleType.Quality then
		iconUrl = self._petInfo.ratingIconUrl
		str = pg.getGameString(self._petInfo.ratingStr)

		if not self._petInfo.ratingStr and LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("PetFertilityIncubateCtrl: renderBubbleError4 self._petInfo.tempId=%s; propertyScoreStag=%s", self._petInfo.templateId, self._petInfo.propertyScoreStage)
		end
	end

	if iconUrl then
		icon.url = iconUrl
	end

	ClientTextUtils.setText(text, str)
end

function PetFertilityIncubateCtrl:refreshInfo()
	self:startTipsTimer()
	self:refreshEggBtnState()
	self:refreshBubble()
	ClientTextUtils.setText(self.view.txtTitieUBaseText, self:getTitleByIndex(self._curIndex))

	if IncubateInfo[self._curIndex].rumble then
		pg.game.input:playRumbleByName(ClientConst.RumbleLayer.PET_INCUBATE, IncubateInfo[self._curIndex].rumble)
	end
end

function PetFertilityIncubateCtrl:refreshEggBtnState()
	for i = 1, #self.view.btnEggList do
		local btn = self.view.btnEggList[i]
		local state = 0

		state = i <= self._curIndex and 2 or self._curIndex == i - 1 and 1 or 0

		btn:TryChangePage("egg", state)
	end
end

function PetFertilityIncubateCtrl:refreshBubble()
	for i = 1, #self.view.bubbleList do
		local bubble = self.view.bubbleList[i]
		local active = i <= self._curIndex

		LuaUIUtils.setUIVisible(bubble, active)
	end
end

function PetFertilityIncubateCtrl:onBtnClickNext()
	if self._nextClickTime and Time.realSecondCache * 1000 < self._nextClickTime then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("PetFertilityIncubateCtrl:onBtnClickNext cd!")
		end

		return
	elseif self._curIndex >= 4 then
		self:dismiss()

		if self._closeCallBack then
			self._closeCallBack()
		end

		return
	else
		self._inAni = true
		self._aniStartTime = Time.realSecondCache * 1000
		self._curIndex = self._curIndex + 1
		self._nextClickTime = self._aniStartTime + SoulEggEvolutionConst.SoulEggClickCD[self._curIndex] * 1000

		self.view.rootComponent:TryChangePage("TouchState", self._curIndex)
		pg.game.audio:playEvent("SFX_UI_Incubate_EggRupture0" .. self._curIndex)
		pg.game.soulEggEvolution:playEggBroken(self._curIndex)
		self:refreshInfo()
	end
end

function PetFertilityIncubateCtrl:startTipsTimer()
	if self.tipsTimer then
		self:killTimer(self.tipsTimer)

		self.tipsTimer = nil
	end

	self.tipsTimer = self:startTimer(function()
		LuaUIUtils.setUIVisible(self.view.hintTxt, true)
	end, SysConfigData.incubateTipsDelay or 3)
end

return PetFertilityIncubateCtrl
