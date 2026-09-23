-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetDispatchSurveyCompleted\\PetDispatchSurveyCompletedCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetDispatchUtils = require("GameApp.PetDispatch.PetDispatchUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local lume = require("Core.Common.lume")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local ClientConst = require("Const.ClientConst")
local RATING_TO_INDEX = {
	A = 1,
	B = 0,
	S = 2
}
local PetDispatchSurveyCompletedCtrl = Class.LightClass("PetDispatchSurveyCompletedCtrl", UICtrl)

PetDispatchSurveyCompletedCtrl.messages = {}

function PetDispatchSurveyCompletedCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetDispatchSurveyCompletedCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	info = info or {}
	self.model.clueId = info.clueId
	self.model.mode = info.mode or "single"
	self.model.eventId = info.eventId

	self:setState(info.defaultState or 0)
end

function PetDispatchSurveyCompletedCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetDispatchSurveyCompletedCtrl:addListener()
	if self.view.backGroundCloseUButton then
		function self.view.backGroundCloseUButton.luaClick()
			self:onBackGroundClick()
		end

		self.view.backGroundCloseUButton:SetGamepadAction("Raw/GamepadButtonSouth")
		self.view.backGroundCloseUButton:SetHotkeyBanRay(true)
		self.view.backGroundCloseUButton:SetHotkeyBypassModalBlocking(false)
	end

	if self.view.BackGroundClose then
		function self.view.BackGroundClose.luaClick()
			self:onBackGroundClick()
		end
	end

	if self.view.listRewardBaseUList then
		function self.view.listRewardBaseUList.luaRenderItem(button, index, data)
			LuaUIUtils.renderRewardItem(button, data)
		end
	end

	if self.view.listRewardAdveUList then
		function self.view.listRewardAdveUList.luaRenderItem(button, index, data)
			LuaUIUtils.renderRewardItem(button, data)
		end
	end
end

function PetDispatchSurveyCompletedCtrl:setState(state)
	self.model.state = state

	if self.view.rootUComponent then
		self.view.rootUComponent:TryChangePage("State", state)
	end

	self:refresh()
	self:refreshTipsTouchAnyConsole()
	self:refreshConsoleBarState()
end

function PetDispatchSurveyCompletedCtrl:onBackGroundClick()
	if self.model.state == 1 then
		if self.view.rootUComponent then
			self.view.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

			self.model.state = 2

			self:refresh()
			self:refreshTipsTouchAnyConsole()
			self:refreshConsoleBarState()
			pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonMiddle")
		end
	else
		local navManager = CS.XGUI.Navigation.NavManager.Instance

		if pg.game.input:isUsingGamepad() and navManager and navManager:IsInModalGroup() then
			return false
		end

		self:dismiss()
	end
end

function PetDispatchSurveyCompletedCtrl:refresh()
	local clueConfig = PetDispatchUtils.getClueConfig(self.model.clueId) or {}

	if self.view.imgPicUImage and clueConfig.clueImage then
		self.view.imgPicUImage.url = clueConfig.clueImage
	end

	if self.view.imgPicLUImage and clueConfig.clueImage then
		self.view.imgPicLUImage.url = clueConfig.clueImage
	end

	if self.view.txtTips then
		local tipsKey = clueConfig.imageDesc
		local text = tipsKey and pg.getLocalizationText(tipsKey) or ""

		ClientTextUtils.setText(self.view.txtTips, text)
	end

	if self.model.state ~= 2 then
		return
	end

	local taskInfo = self.model.clueId and ClientActivityUtils.getTaskInfoByTaskId(ActivityConst.EventType.PetDispatch, self.model.clueId) or nil

	self:refreshBaseReward(taskInfo, clueConfig)
	self:refreshAdventureReward(taskInfo, clueConfig)
end

function PetDispatchSurveyCompletedCtrl:refreshBaseReward(taskInfo, clueConfig)
	if self.view.baserewardUWidget then
		self.view.baserewardUWidget.gameObject:SetActiveEx(true)
	end

	local petList = {}

	if taskInfo and taskInfo.sparam then
		local disPatchInfo = lume.deserialize(taskInfo.sparam)

		petList = disPatchInfo and disPatchInfo.dispatchPetList or {}
	end

	if self.view.textBaseDes then
		local names = {}

		for _, petId in ipairs(petList) do
			local name = LuaUIUtils.getPetName(petId)

			if type(name) == "number" then
				name = pg.getLocalizationText(name)
			end

			if name and name ~= "" then
				names[#names + 1] = tostring(name)
			end
		end

		local awardDes = clueConfig.awardDes and pg.getLocalizationText(clueConfig.awardDes) or ""

		ClientTextUtils.setText(self.view.textBaseDes, table.concat(names, "、") .. awardDes)
	end

	if self.view.listRewardBaseUList then
		self.view.listRewardBaseUList.gameObject:SetActiveEx(true)

		local team = {}

		for _, petId in ipairs(petList) do
			team[#team + 1] = {
				id = petId
			}
		end

		local conditions = PetDispatchUtils.getExtraConditions(self.model.clueId) or {}
		local rating = PetDispatchUtils.calcRating(team, conditions)
		local index = RATING_TO_INDEX[rating] or 0
		local dropId = clueConfig.extraAward and clueConfig.extraAward[index]
		local rewards = dropId and LuaUIUtils.getRewardItemByDropId(dropId) or {}

		self.view.listRewardBaseUList:SetList(rewards)
	end
end

function PetDispatchSurveyCompletedCtrl:refreshAdventureReward(taskInfo, clueConfig)
	local disPatchInfo = taskInfo and taskInfo.sparam and lume.deserialize(taskInfo.sparam) or nil
	local rewardIndex = disPatchInfo and disPatchInfo.adventureRewardId or 0
	local triggered = rewardIndex and rewardIndex > 0

	if self.view.adveRewardUWidget then
		self.view.adveRewardUWidget.gameObject:SetActiveEx(triggered)
	end

	if not triggered then
		if self.view.petUWidget then
			self.view.petUWidget.gameObject:SetActiveEx(false)
		end

		if self.view.listRewardAdveUList then
			self.view.listRewardAdveUList.gameObject:SetActiveEx(false)
		end

		return
	end

	if self.view.textAdveRewardAdveDes then
		local desKey = clueConfig.mysteryAwardDes

		ClientTextUtils.setText(self.view.textAdveRewardAdveDes, desKey and pg.getLocalizationText(desKey) or "")
	end

	local activityData = pg.me and ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.PetDispatch)
	local phase = activityData and activityData.eventPhase or 1
	local entry = PetDispatchUtils.getAdventureRewardEntry(phase, rewardIndex)
	local entryType = entry and entry[1] or 0
	local entryValue = entry and entry[2]
	local isPet = entryType == 1

	if self.view.petUWidget then
		self.view.petUWidget.gameObject:SetActiveEx(isPet)
	end

	if self.view.listRewardAdveUList then
		self.view.listRewardAdveUList.gameObject:SetActiveEx(not isPet)
	end

	if isPet then
		self:renderAdventurePet(disPatchInfo)
	elseif entryValue then
		local rewards = LuaUIUtils.getRewardItemByDropId(entryValue) or {}

		self.view.listRewardAdveUList:SetList(rewards)
	end
end

function PetDispatchSurveyCompletedCtrl:renderAdventurePet(disPatchInfo)
	local leaderId = disPatchInfo and disPatchInfo.dispatchPetList and disPatchInfo.dispatchPetList[1]
	local petInfo = leaderId and pg.me and pg.me:getPetInfo(leaderId)
	local pet = petInfo and LuaUIUtils.getDispatchPetInfo(petInfo)

	if self.view.petHeadUButton then
		local objectReference = self.view.petHeadUButton:GetComponent("ObjectReference")
		local iconUImage = objectReference and objectReference:GetRefValue("iconUImage")

		if iconUImage and pet then
			iconUImage.url = LuaUIUtils.getPetIcon(pet.iconName, LuaUIUtils.PET_ICON, pet.label, pet.gender)
		end

		if self.view.petHeadUButton.TryChangePage and pet then
			self.view.petHeadUButton:TryChangePage("Type", pet.isShiny and 1 or 0)
		end
	end

	if self.view.txtAttriUSDFText then
		ClientTextUtils.setText(self.view.txtAttriUSDFText, "")
	end

	if self.view.txtNumBeforeUSDFText then
		ClientTextUtils.setText(self.view.txtNumBeforeUSDFText, "")
	end

	if self.view.txtNumAfterUSDFText then
		ClientTextUtils.setText(self.view.txtNumAfterUSDFText, "")
	end

	local enhancedValueMap = disPatchInfo and disPatchInfo.enhancedValueMap

	if not enhancedValueMap or not petInfo or not petInfo.basePropertyList then
		return
	end

	local idx, value = next(enhancedValueMap)

	if not idx or not value then
		return
	end

	local baseProp = petInfo.basePropertyList[idx]
	local afterV = baseProp and baseProp.indLv or 0
	local beforeV = afterV - value

	if beforeV < 0 then
		beforeV = 0
	end

	local nameKey = PetManagementDataHelper.NEW_PROP_NAMES[idx]
	local nameText = nameKey and pg.getGameString(nameKey) or ""

	if self.view.txtAttriUSDFText then
		ClientTextUtils.setText(self.view.txtAttriUSDFText, nameText)
	end

	if self.view.txtNumBeforeUSDFText then
		ClientTextUtils.setText(self.view.txtNumBeforeUSDFText, tostring(beforeV))
	end

	if self.view.txtNumAfterUSDFText then
		ClientTextUtils.setText(self.view.txtNumAfterUSDFText, tostring(afterV))
	end
end

function PetDispatchSurveyCompletedCtrl:refreshTipsTouchAnyConsole()
	if self.view.tipsTouchAnyConsoleUWidget then
		self.view.tipsTouchAnyConsoleUWidget:SetActive(self.model.state == 1)
	end
end

function PetDispatchSurveyCompletedCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function PetDispatchSurveyCompletedCtrl:refreshConsoleBarState()
	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ThemeMonth_SurveyComplete_Detail", self.model.state == 2, true)
	end
end

return PetDispatchSurveyCompletedCtrl
